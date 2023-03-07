// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureCardPaymentDomain
import PlatformKit
import ToolKit
import UIKit

public protocol CardComponentBuilderAPI: AnyObject {

    /// Builds a card details screen
    func cardDetails() -> UIViewController

    /// Builds a billing address screen
    func billingAddress(for cardData: CardData, navigationControllerAPI: NavigationControllerAPI) -> UIViewController

    /// Builds a pending card status screen (hangs until card is approved)
    func pendingCardStatus(cardId: String) -> UIViewController

    /// Builds a card authorization screen
    func cardAuthorization(for data: PartnerAuthorizationData) -> UIViewController?
}

public final class CardComponentBuilder: CardComponentBuilderAPI {

    private let routingInteractor: CardRouterInteractor
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let messageRecorder: MessageRecording
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private var stripeClient: StripeUIClientAPI

    public init(
        routingInteractor: CardRouterInteractor,
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        messageRecorder: MessageRecording = resolve(),
        stripeClient: StripeUIClientAPI = resolve()
    ) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.routingInteractor = routingInteractor
        self.analyticsRecorder = analyticsRecorder
        self.messageRecorder = messageRecorder
        self.stripeClient = stripeClient
    }

    public func cardDetails() -> UIViewController {
        let interactor = CardDetailsScreenInteractor(
            routingInteractor: routingInteractor
        )
        let presenter = CardDetailsScreenPresenter(
            interactor: interactor,
            eventRecorder: analyticsRecorder,
            messageRecorder: messageRecorder
        )
        let viewController = CardDetailsScreenViewController(presenter: presenter)
        return viewController
    }

    public func pendingCardStatus(cardId: String) -> UIViewController {
        let interactor = PendingCardStatusInteractor(
            cardId: cardId,
            paymentMethodTypesService: paymentMethodTypesService,
            routingInteractor: routingInteractor
        )
        let presenter = PendingCardStatusPresenter(interactor: interactor)
        let viewController = PendingStateViewUXErrorController(
            presenter: presenter
        )
        return viewController
    }

    public func cardAuthorization(for data: PartnerAuthorizationData) -> UIViewController? {
        let interactor = CardAuthorizationScreenInteractor(routingInteractor: routingInteractor)
        let presenter = CardAuthorizationScreenPresenter(
            interactor: interactor,
            data: data,
            eventRecorder: analyticsRecorder
        )

        guard case .required(let params) = data.state else {
            presenter.redirect()
            return nil
        }

        switch params.cardAcquirer {
        case .stripe:
            stripeClient.confirmPayment(data, with: presenter)
            return nil
        case .everyPay, .checkout, .unknown, .fake:
            let viewController = CardAuthorizationScreenViewController(
                presenter: presenter
            )
            return viewController
        }
    }

    public func billingAddress(
        for cardData: CardData,
        navigationControllerAPI: NavigationControllerAPI
    ) -> UIViewController {
        let selectionRouter = SelectionRouter(parent: navigationControllerAPI)
        let interactor = BillingAddressScreenInteractor(
            cardData: cardData,
            routingInteractor: routingInteractor
        )
        let presenter = BillingAddressScreenPresenter(
            interactor: interactor,
            countrySelectionRouter: selectionRouter,
            eventRecorder: analyticsRecorder,
            messageRecorder: messageRecorder
        )
        let viewController = BillingAddressScreenViewController(
            presenter: presenter
        )
        return viewController
    }
}

extension CardAuthorizationScreenPresenter: CardAuthorizationScreenPresenterAPI {}
