// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct SnapshotTraitRepository: TraitRepositoryAPI {
    public var traitsDidChange: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher()
    public var traits: [String: String] = [:]
    public init(_ traits: [String: String] = [:]) {
        self.traits = traits
    }
}

public final class NabuAnalyticsProvider: AnalyticsServiceProviderAPI {

    public var supportedEventTypes: [AnalyticsEventType] = [.nabu]

    private let platform: Platform
    private let batchSize: Int
    private let updateTimeInterval: TimeInterval
    private var lastFailureTimeInterval: TimeInterval = 0
    private var consequentFailureCount: Double = 0
    private var backoffDelay: Double {
        let delay = Int(pow(2, consequentFailureCount) * 10).subtractingReportingOverflow(1)
        return Double(delay.overflow ? .max : delay.partialValue + 1)
    }

    private let fileCache: FileCacheAPI
    private let eventsRepository: NabuAnalyticsEventsRepositoryAPI
    private let traitRepository: TraitRepositoryAPI
    private let contextProvider: ContextProviderAPI
    private let guidProvider: GuidRepositoryAPI
    private let notificationCenter: NotificationCenter

    private let queue: DispatchQueue

    private var cancellables = Set<AnyCancellable>()

    @Published private var events = [Event]()

    public convenience init(
        platform: Platform,
        basePath: String,
        userAgent: String,
        tokenProvider: @escaping TokenProvider,
        guidProvider: GuidRepositoryAPI,
        traitRepository: TraitRepositoryAPI = SnapshotTraitRepository()
    ) {
        let client = APIClient(basePath: basePath, userAgent: userAgent)
        let eventsRepository = NabuAnalyticsEventsRepository(client: client, tokenProvider: tokenProvider)
        let contextProvider = ContextProvider(guidProvider: guidProvider, traitRepository: traitRepository)
        self.init(
            platform: platform,
            eventsRepository: eventsRepository,
            contextProvider: contextProvider,
            guidProvider: guidProvider,
            traitRepository: traitRepository
        )
    }

    init(
        platform: Platform,
        batchSize: Int = 20,
        updateTimeInterval: TimeInterval = 30,
        fileCache: FileCacheAPI = FileCache(),
        eventsRepository: NabuAnalyticsEventsRepositoryAPI,
        contextProvider: ContextProviderAPI,
        guidProvider: GuidRepositoryAPI,
        traitRepository: TraitRepositoryAPI = SnapshotTraitRepository(),
        notificationCenter: NotificationCenter = .default,
        queue: DispatchQueue = .init(label: "AnalyticsKit", qos: .background)
    ) {
        self.platform = platform
        self.batchSize = batchSize
        self.updateTimeInterval = updateTimeInterval
        self.fileCache = fileCache
        self.eventsRepository = eventsRepository
        self.contextProvider = contextProvider
        self.notificationCenter = notificationCenter
        self.queue = queue
        self.traitRepository = traitRepository
        self.guidProvider = guidProvider

        setupBatching()
    }

    private func setupBatching() {
        queue.sync { [weak self] in
            guard let self else { return }

            // Sending triggers

            let updateRateTimer = Timer
                .publish(every: updateTimeInterval, on: .current, in: .default)
                .autoconnect()
                .withLatestFrom($events)

            let batchFull = $events
                .filter { $0.count >= self.batchSize }

            let onChange = traitRepository.traitsDidChange
                .withLatestFrom($events)

            #if canImport(UIKit)
            let enteredBackground = notificationCenter
                .publisher(for: UIApplication.willResignActiveNotification)
                .withLatestFrom($events)

            updateRateTimer
                .merge(with: batchFull)
                .merge(with: enteredBackground)
                .merge(with: onChange)
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .withLatestFrom(
                    traitRepository.traitsDidChange.map { [contextProvider] in contextProvider.context.traits }
                        .prepend(contextProvider.context.traits),
                    selector: { (events: $0, context: $1) }
                )
                .subscribe(on: queue)
                .receive(on: queue)
                .sink { [weak self] events, context in
                    guard let self else { return }
                    send(
                        events: events,
                        contextProvider: ContextProvider(
                            guidProvider: guidProvider,
                            traitRepository: SnapshotTraitRepository(context)
                        )
                    )
                }
                .store(in: &cancellables)

            // Reading cache

            notificationCenter
                .publisher(for: UIApplication.didEnterBackgroundNotification)
                .receive(on: queue)
                .compactMap { _ in self.fileCache.read() }
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .subscribe(on: queue)
                .receive(on: queue)
                .sink(receiveValue: send)
                .store(in: &cancellables)
            #endif
        }
    }

    public func trackEvent(title: String, parameters: [String: Any]?) {
        queue.sync { [weak self] in
            self?.events.append(Event(title: title, properties: parameters))
        }
    }

    private func send(events: [Event]) {
        send(events: events, contextProvider: contextProvider)
    }

    private func send(events: [Event], contextProvider: ContextProviderAPI) {
        self.events = self.events.filter { !events.contains($0) }
        // This is simple backoff logic:
        // If time elapsed between now and last failure is greater than backoffDelay - try sending,
        // Otherwise - save to file cache and don't send the request.
        if Date().timeIntervalSince1970 - lastFailureTimeInterval <= backoffDelay {
            fileCache.save(events: events)
            return
        }

        let eventsWrapper = EventsWrapper(contextProvider: contextProvider, events: events, platform: platform)
        eventsRepository.publish(events: eventsWrapper)
            .subscribe(on: queue)
            .receive(on: queue)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure(let error):
                    if Constants.allowedErrorCodes.contains(error.errorCode)
                        || error.networkUnavailableReason != nil
                    {
                        fileCache.save(events: events)
                    }
                    consequentFailureCount += 1
                    lastFailureTimeInterval = Date().timeIntervalSince1970
                case .finished:
                    consequentFailureCount = 0
                    lastFailureTimeInterval = 0
                }
            } receiveValue: { _ in
                // NOOP
            }
            .store(in: &cancellables)
    }

    private enum Constants {
        static let allowedErrorCodes = 500...599
    }
}

extension Publisher {

    public func scan() -> AnyPublisher<(newValue: Output, oldValue: Output), Failure> {
        scan(count: 2)
            .map { ($0[1], $0[0]) }
            .eraseToAnyPublisher()
    }

    public func scan(count: Int) -> AnyPublisher<[Output], Failure> {
        scan([]) { ($0 + [$1]).suffix(count) }
            .filter { $0.count == count }
            .eraseToAnyPublisher()
    }
}
