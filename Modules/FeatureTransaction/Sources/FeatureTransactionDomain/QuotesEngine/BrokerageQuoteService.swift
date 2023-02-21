import Blockchain
import DIKit
import PlatformKit

public protocol BrokerageQuoteRepositoryProtocol {

    func get(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Price

    func create(
        base: Currency,
        quote: Currency,
        amount: String,
        paymentMethod: BrokerageQuote.PaymentMethod,
        paymentMethodId: String?,
        profile: BrokerageQuote.Profile
    ) async throws -> BrokerageQuote.Response
}

public protocol LegacyCustodialQuoteRepositoryProtocol: BrokerageQuoteRepositoryProtocol { }

public final class BrokerageQuoteService {

    let app: AppProtocol
    let scheduler: AnySchedulerOf<DispatchQueue>

    var legacy: LegacyCustodialQuoteRepositoryProtocol
    var new: BrokerageQuoteRepositoryProtocol

    var repository: BrokerageQuoteRepositoryProtocol {
        get async {
            (try? await app.get(blockchain.ux.transaction.checkout.quote.brokerage.is.enabled)) == false ? legacy : new
        }
    }

    public init(
        app: AppProtocol,
        legacy: LegacyCustodialQuoteRepositoryProtocol,
        new: BrokerageQuoteRepositoryProtocol,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.app = app
        self.legacy = legacy
        self.new = new
        self.scheduler = scheduler
    }

    public func quotes(
        _ request: BrokerageQuote.Request
    ) -> AnyPublisher<Result<BrokerageQuote, UX.Error>, Never> {
        let subject = PassthroughSubject<Result<BrokerageQuote, UX.Error>, Never>()
        let task = Task { [app] in
            do {
                let backoff = ExponentialBackoff()
                repeat {
                    try Task.checkCancellation()
                    var quote: BrokerageQuote.Response
                    do {
                        quote = try await repository.create(
                            base: request.base,
                            quote: request.quote,
                            amount: request.amount.minorString,
                            paymentMethod: request.paymentMethod,
                            paymentMethodId: request.paymentMethodId,
                            profile: request.profile
                        )
                    } catch {
                        guard await backoff.count() < 8 else { throw error }
                        try await backoff.next()
                        continue
                    }

                    do {
                        let max = try await Date().addingTimeInterval(app.get(blockchain.ux.transaction.checkout.quote.refresh.max.duration))
                        quote.expiresAt = min(quote.expiresAt, BrokerageQuote.Response.formatter.string(from: max))
                    } catch { /* ignored */ }

                    try Task.checkCancellation()
                    subject.send(.success(BrokerageQuote(request: request, response: quote)))

                    guard let expires = quote.date.expiresAt else { break }
                    if expires.timeIntervalSinceNow > 0 {
                        try await scheduler.sleep(until: .init(.now() + .seconds(expires.timeIntervalSinceNow)))
                        try Task.checkCancellation()
                        await backoff.reset()
                    } else {
                        try await backoff.next()
                    }
                } while !Task.isCancelled
            } catch is CancellationError { /* ignored */ } catch {
                subject.send(.failure(UX.Error(error: error)))
            }
            subject.send(completion: .finished)
        }
        return subject.handleEvents(
            receiveCancel: task.cancel
        ).eraseToAnyPublisher()
    }

    public func prices(
        _ request: BrokerageQuote.Request,
        every interval: DispatchTimeInterval = .seconds(5)
    ) -> AnyPublisher<Result<BrokerageQuote.Price, UX.Error>, Never> {
        let subject = PassthroughSubject<Result<BrokerageQuote.Price, UX.Error>, Never>()
        let task = Task {
            do {
                repeat {
                    try Task.checkCancellation()
                    let price: BrokerageQuote.Price
                    do {
                        price = try await repository.get(
                            base: request.base,
                            quote: request.quote,
                            amount: request.amount.minorString,
                            paymentMethod: request.paymentMethod,
                            profile: request.profile
                        )
                        do {
                            try Task.checkCancellation()
                            subject.send(.success(price))
                        } catch is CancellationError {
                            break
                        }
                    } catch {
                        subject.send(.failure(UX.Error(error: error)))
                    }
                    try await scheduler.sleep(for: .init(interval))
                } while !Task.isCancelled
            } catch { /* ignored */ }
            subject.send(completion: .finished)
        }
        return subject.handleEvents(receiveCancel: task.cancel).eraseToAnyPublisher()
    }
}
