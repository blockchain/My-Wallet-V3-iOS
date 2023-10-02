// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardPaymentDomain
import PlatformKit
import RIBs
import RxSwift

final class CardDetailsScreenInteractor: Interactor {

    // MARK: - Properties

    var supportedCardTypes: Single<Set<CardType>> {
        paymentMethodsService.supportedCardTypes
    }

    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let cardListService: CardListServiceAPI
    private let routingInteractor: CardRouterInteractor
    private let cardService: CardServiceAPI

    // MARK: - Setup

    init(
        routingInteractor: CardRouterInteractor,
        paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
        cardListService: CardListServiceAPI = resolve(),
        cardService: CardServiceAPI = resolve()
    ) {
        self.routingInteractor = routingInteractor
        self.paymentMethodsService = paymentMethodsService
        self.cardListService = cardListService
        self.cardService = cardService
        self.cardService.isEnteringDetails = true
    }

    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool> {
        cardListService
            .doesCardExist(number: number, expiryMonth: expiryMonth, expiryYear: expiryYear)
            .asSingle()
    }

    func addBillingAddress(to cardData: CardData) {
        routingInteractor.addBillingAddress(to: cardData)
        cardService.isEnteringDetails = false
    }

    func cancel() {
        routingInteractor.previousRelay.accept(())
        cardService.isEnteringDetails = false
    }
}
