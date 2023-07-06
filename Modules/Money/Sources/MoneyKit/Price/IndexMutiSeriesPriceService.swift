import BlockchainNamespace
import CombineSchedulers
import DIKit
import Extensions
import NetworkKit

public actor IndexMutiSeriesPriceService {

    public typealias Stream = AsyncFlatMapSequence<AsyncStream<AsyncStream<Price?>>, AsyncStream<Price?>>
    public typealias Continuation = AsyncStream<AsyncStream<Price?>>.Continuation
    public typealias BufferingPolicy = AsyncStream<Price?>.Continuation.BufferingPolicy

    public class Source {
        internal var fetched: Bool = false
        internal var error: Error?
        internal var errorCount: Int = 0
        fileprivate(set) var cancelTimestamp: DispatchTime?
        fileprivate(set) var referenceCount: Int = 0
        fileprivate(set) var pendingContinuations: [PendingContinuation]?
        fileprivate init(pending: PendingContinuation) {
            self.pendingContinuations = [pending]
        }
    }

    public struct PendingContinuation {
        let currencyPair: CurrencyPairAndTime
        let bufferingPolicy: BufferingPolicy
        let continuation: Continuation
    }

    let app: AppProtocol
    let logger: NetworkDebugLogger?
    let session: URLSession
    let scheduler: AnySchedulerOf<DispatchQueue>

    var refreshInterval: DispatchQueue.SchedulerTimeType.Stride

    public var subscriptions: Set<CurrencyPairAndTime> { sources.keys.set }

    var cancellingGracePeriod: DispatchQueue.SchedulerTimeType.Stride
    var sources: Dictionary<CurrencyPairAndTime, Source> = [:]
    var store = Dictionary<CurrencyPairAndTime, Price>.Store()

    var observation: Task<Void, Error>?

    public init(
        app: AppProtocol,
        logger: NetworkDebugLogger? = nil,
        session: URLSession = .shared,
        scheduler: AnySchedulerOf<DispatchQueue>,
        refreshInterval: DispatchQueue.SchedulerTimeType.Stride,
        cancellingGracePeriod: DispatchQueue.SchedulerTimeType.Stride
    ) {
        self.app = app
        self.logger = logger
        self.session = session
        self.scheduler = scheduler
        self.refreshInterval = refreshInterval
        self.cancellingGracePeriod = cancellingGracePeriod
        Task { await observe() }
    }

    func observe() {
        self.observation = Task {
            try await withThrowingTaskGroup(of: Void.self) { [self] group in
                group.addTask {
                    for try await _ in self.scheduler.timer(interval: .seconds(1)) {
                        let fetch = await self.sources.filter(\.value.fetched.isNo)
                        guard fetch.isNotEmpty else { continue }
                        for (_, value) in fetch { value.fetched = true }
                        do {
                            try await self.request(fetch.filter(\.value.errorCount < 2).map(\.key))
                        } catch {
                            for (pair, source) in fetch {
                                source.fetched = false
                                source.error = error
                                source.errorCount += 1
                                let pendingContinuations = source.pendingContinuations
                                source.pendingContinuations = nil
                                for pending in pendingContinuations.or(default: []) {
                                    await self.yield(pair, to: pending.continuation, bufferingPolicy: pending.bufferingPolicy, with: source)
                                }
                            }
                            self.app.post(error: error)
                        }
                    }
                }
                group.addTask {
                    for await _ in await self.scheduler.timer(interval: self.refreshInterval) {
                        let fetch = await self.sources.keys.filter(\.time.isNil)
                        guard fetch.isNotEmpty else { continue }
                        do {
                            try await self.request(fetch.array)
                        } catch {
                            self.app.post(error: error)
                        }
                    }
                }
                try await group.waitForAll()
            }
        }
    }

    nonisolated public func publisher(for currencyPair: CurrencyPairAndTime, bufferingPolicy limit: BufferingPolicy = .unbounded) -> AnyPublisher<Price?, Never> {
        Task.Publisher { await stream(currencyPair, bufferingPolicy: limit).publisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    public func stream(_ currencyPair: CurrencyPairAndTime, bufferingPolicy limit: BufferingPolicy = .unbounded) -> Stream {
        AsyncStream { continuation in
            Task { try await stream(currencyPair, to: continuation, bufferingPolicy: limit) }
        }.flatMap { $0 }
    }

    private func stream(_ currencyPair: CurrencyPairAndTime, to continuation: Continuation, bufferingPolicy limit: BufferingPolicy) async throws {
        switch sources[currencyPair] {
        case let source?:
            if source.pendingContinuations.isNil {
                yield(currencyPair, to: continuation, bufferingPolicy: limit, with: source)
            } else {
                source.pendingContinuations?.append(
                    PendingContinuation(currencyPair: currencyPair, bufferingPolicy: limit, continuation: continuation)
                )
            }
        default:
            let source = Source(
                pending: PendingContinuation(currencyPair: currencyPair, bufferingPolicy: limit, continuation: continuation)
            )
            sources[currencyPair] = source
            if await store.dictionary[currencyPair].isNotNil {
                source.fetched = true
                yield(currencyPair, to: continuation, bufferingPolicy: limit, with: source)
            }
        }
    }

    private func yield(
        _ currencyPair: CurrencyPairAndTime,
        to continuation: Continuation,
        bufferingPolicy limit: BufferingPolicy,
        with source: Source
    ) {
        let stream = AsyncStream<Price?> { continuation in
            count(for: currencyPair, of: +1)
            let task = Task {
                for await price in await store.stream(currencyPair, bufferingPolicy: limit) {
                    continuation.yield(price)
                }
            }
            continuation.onTermination = { @Sendable [weak self] _ in
                task.cancel()
                Task { [weak self] in await self?.count(for: currencyPair, of: -1) }
            }
        }
        continuation.yield(stream)
    }

    private func count(for currencyPair: CurrencyPairAndTime, of change: Int) {
        guard let source = sources[currencyPair] else {
            app.post(error: "😱 Reference counting (\(change)) of non existent source '\(currencyPair)'")
            return assertionFailure("😱 Reference counting (\(change)) of non existent source '\(currencyPair)'")
        }
        let result = source.referenceCount + change
        if result > 0 {
            source.referenceCount = result
            source.cancelTimestamp = nil
        } else if cancellingGracePeriod > 0 {
            source.cancelTimestamp = .now()
            Task { [t = source.cancelTimestamp, duration = cancellingGracePeriod] in
                try await scheduler.sleep(for: duration)
                guard source.cancelTimestamp == t else { return }
                cancel(currencyPair)
            }
        } else {
            cancel(currencyPair)
        }
    }

    private func cancel(_ currencyPair: CurrencyPairAndTime) {
        sources.removeValue(forKey: currencyPair)
    }

    private func request(_ body: [CurrencyPairAndTime]) async throws {
        let (now, timestamp) = body.partitioned(by: \.time.isNotNil)

        async let indexMulti = IndexMultiRequest(body: now.map(\.currencyPair)).request(on: session, logger: logger).array.map { currencyPair, price in
            (CurrencyPairAndTime(base: currencyPair.base, quote: currencyPair.quote, time: nil), price)
        }

        async let indexMultiSeries = IndexMultiSeriesRequest(body: timestamp).request(on: session, logger: logger).array.flatMap { currencyPair, prices in
            prices.map { price in (CurrencyPairAndTime(base: currencyPair.base, quote: currencyPair.quote, time: price.timestamp), price) }
        }

        let response = try await indexMulti + indexMultiSeries

        await store.transaction { store in
            for (currencyPair, price) in response {
                await store.set(currencyPair, to: price)
            }
        }

        for currencyPair in body {
            guard let source = sources[currencyPair] else { continue }
            if let pendingContinuations = source.pendingContinuations {
                source.pendingContinuations = nil
                for pending in pendingContinuations {
                    yield(currencyPair, to: pending.continuation, bufferingPolicy: pending.bufferingPolicy, with: source)
                }
            }
        }
    }
}
