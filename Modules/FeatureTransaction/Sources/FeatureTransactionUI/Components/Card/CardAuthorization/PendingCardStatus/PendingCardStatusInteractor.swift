// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Errors
import FeatureCardPaymentDomain
import FeatureOpenBankingDomain
import PlatformKit
import RIBs
import RxSwift
import RxToolKit

final class PendingCardStatusInteractor: Interactor {

    // MARK: - Types

    enum State {
        case active(CardData)
        case inactive(Swift.Error)
        case timeout
    }

    enum Error: Swift.Error {
        case noData
    }

    // MARK: - Properties

    private let cardId: String
    private let activationService: CardActivationServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let routingInteractor: CardRouterInteractor

    // MARK: - Setup

    init(
        cardId: String,
        activationService: CardActivationServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI,
        routingInteractor: CardRouterInteractor
    ) {
        self.cardId = cardId
        self.routingInteractor = routingInteractor
        self.activationService = activationService
        self.paymentMethodTypesService = paymentMethodTypesService
    }

    func startPolling() -> Single<State> {
        activationService
            .waitForActivation(of: cardId)
            .asSingle()
            .flatMap(weak: self) { (self, result) -> Single<State> in
                switch result {
                case .success(let state):
                    switch state {
                    case .active(let data):
                        return self.paymentMethodTypesService
                            .fetchCards(andPrefer: data.identifier)
                            .andThen(Single.just(.active(data)))
                    case .inactive(let data):
                        let error: Swift.Error? = data?.ux.map(UX.Error.init(nabu:))
                        return .just(
                            .inactive(
                                error ?? (data?.lastError).map(OpenBanking.Error.code) ?? Error.noData
                            )
                        )
                    case .pending:
                        return .just(.timeout)
                    }
                case .failure(let error):
                    guard case .timeout = error else {
                        return .just(.inactive(error))
                    }
                    return .just(.timeout)
                }
            }
    }

    /// End the polling in confirmation state
    /// - Parameter cardData: The data of the card
    func endWithConfirmation(with cardData: CardData) {
        routingInteractor.end(with: cardData)
    }

    /// End the polling without confirmation
    func endWithoutConfirmation() {
        routingInteractor.dismiss()
    }
}
