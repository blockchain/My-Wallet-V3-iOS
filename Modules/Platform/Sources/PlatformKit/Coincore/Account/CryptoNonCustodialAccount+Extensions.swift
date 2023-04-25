// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine

extension CryptoNonCustodialAccount {

    public var canPerformInterestTransfer: AnyPublisher<Bool, Never> {
        isFunded
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    /// Treats an `[TransactionalActivityItemEvent]`, replacing any event matching one of the `SwapActivityItemEvent` with the said match.
    public static func reconcile(
        swapEvents: [SwapActivityItemEvent],
        noncustodial: [TransactionalActivityItemEvent]
    ) -> [ActivityItemEvent] {
        (noncustodial.map(ActivityItemEvent.transactional) + swapEvents.map(ActivityItemEvent.swap))
            .map { event in
                if case .swap(let swapEvent) = event, swapEvent.pair.outputCurrencyType.isFiatCurrency {
                    return .buySell(.init(swapActivityItemEvent: swapEvent))
                }
                return event
            }
    }

    /// The `OrderDirection` for which an `CryptoNonCustodialAccount` could have custodial events.
    public var custodialDirections: Set<OrderDirection> {
        [.fromUserKey, .onChain]
    }

    public func shouldUseUnifiedBalance(app: AppProtocol) -> AnyPublisher<Bool, Never> {
        app
            .publisher(
                for: blockchain.app.configuration.unified.balance.coincore.is.setup,
                as: Bool.self
            )
            .prefix(1)
            .map { $0.value ?? false }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
