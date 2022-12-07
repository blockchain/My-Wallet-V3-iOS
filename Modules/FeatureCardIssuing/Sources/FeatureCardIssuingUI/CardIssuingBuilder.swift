// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCardIssuingDomain
import SwiftUI
import UIKit

public protocol CardIssuingBuilderAPI: AnyObject {

    func makeIntroViewController(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        kyc: KYC,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> UIViewController

    func makeIntroView(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        kyc: KYC,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> AnyView

    func makeManagementViewController(
        selectedCard: Card?,
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController

    func makeManagementView(
        selectedCard: Card?,
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> AnyView

    func makeSelectorViewController(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController
}

final class CardIssuingBuilder: CardIssuingBuilderAPI {

    private let accountModelProvider: AccountProviderAPI
    private let app: AppProtocol
    private let cardService: CardServiceAPI
    private let kycService: KYCServiceAPI
    private let legalService: LegalServiceAPI
    private let productService: ProductsServiceAPI
    private let residentialAddressService: CardIssuingAddressServiceAPI
    private let shippingAddressService: CardIssuingAddressServiceAPI
    private let transactionService: TransactionServiceAPI
    private let supportRouter: SupportRouterAPI
    private let userInfoProvider: UserInfoProviderAPI
    private let topUpRouter: TopUpRouterAPI
    private let addressSearchRouter: AddressSearchRouterAPI
    private let shippingAddressSearchRouter: AddressSearchRouterAPI

    init(
        accountModelProvider: AccountProviderAPI,
        app: AppProtocol,
        cardService: CardServiceAPI,
        kycService: KYCServiceAPI,
        legalService: LegalServiceAPI,
        productService: ProductsServiceAPI,
        residentialAddressService: CardIssuingAddressServiceAPI,
        shippingAddressService: CardIssuingAddressServiceAPI,
        transactionService: TransactionServiceAPI,
        supportRouter: SupportRouterAPI,
        userInfoProvider: UserInfoProviderAPI,
        topUpRouter: TopUpRouterAPI,
        addressSearchRouter: AddressSearchRouterAPI,
        shippingAddressSearchRouter: AddressSearchRouterAPI
    ) {
        self.accountModelProvider = accountModelProvider
        self.app = app
        self.cardService = cardService
        self.kycService = kycService
        self.legalService = legalService
        self.productService = productService
        self.residentialAddressService = residentialAddressService
        self.shippingAddressService = shippingAddressService
        self.transactionService = transactionService
        self.supportRouter = supportRouter
        self.userInfoProvider = userInfoProvider
        self.topUpRouter = topUpRouter
        self.addressSearchRouter = addressSearchRouter
        self.shippingAddressSearchRouter = shippingAddressSearchRouter
    }

    func makeIntroViewController(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        kyc: KYC,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> UIViewController {

        UIHostingController(
            rootView: makeIntroView(
                address: address,
                kyc: kyc,
                onComplete: onComplete
            )
        )
    }

    func makeIntroView(
        address: AnyPublisher<Card.Address, CardOrderingError>,
        kyc: KYC,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> AnyView {

        let env = CardOrderingEnvironment(
            mainQueue: .main,
            cardService: cardService,
            kycService: kycService,
            legalService: legalService,
            productsService: productService,
            residentialAddressService: residentialAddressService,
            shippingAddressService: shippingAddressService,
            addressSearchRouter: addressSearchRouter,
            shippingAddressSearchRouter: shippingAddressSearchRouter,
            supportRouter: supportRouter,
            userInfoProvider: userInfoProvider,
            onComplete: onComplete
        )

        let store = Store<CardOrderingState, CardOrderingAction>(
            initialState: .init(initialKyc: kyc),
            reducer: cardOrderingReducer,
            environment: env
        )

        switch kyc.status {
        case .success, .unverified:
            return AnyView(CardIssuingIntroView(store: store))
        case .failure, .pending:
            return AnyView(KYCIntroView(store: store))
        }
    }

    func makeManagementViewController(
        selectedCard: Card?,
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController {

        UIHostingController(
            rootView: makeManagementView(
                selectedCard: selectedCard,
                openAddCardFlow: openAddCardFlow,
                onComplete: onComplete
            )
        )
    }

    func makeManagementView(
        selectedCard: Card?,
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> AnyView {

        let env = CardManagementEnvironment(
            accountModelProvider: accountModelProvider,
            cardIssuingBuilder: self,
            cardService: cardService,
            legalService: legalService,
            mainQueue: .main,
            productsService: productService,
            transactionService: transactionService,
            supportRouter: supportRouter,
            userInfoProvider: userInfoProvider,
            topUpRouter: topUpRouter,
            addressSearchRouter: addressSearchRouter,
            notificationCenter: NotificationCenter.default,
            openAddCardFlow: openAddCardFlow,
            close: onComplete
        )

        let store = Store<CardManagementState, CardManagementAction>(
            initialState: .init(
                card: selectedCard,
                isTokenisationEnabled: isEnabled(blockchain.app.configuration.card.issuing.tokenise.is.enabled),
                tokenisationCoordinator: PassTokenisationCoordinator(service: cardService)
            ),
            reducer: cardManagementReducer,
            environment: env
        )

        return AnyView(CardManagementView(store: store))
    }

    private func isEnabled(_ tag: Tag.Event) -> Bool {
        guard let value = try? app.remoteConfiguration.get(tag) else {
            return false
        }
        guard let isEnabled = value as? Bool else {
            return false
        }
        return isEnabled
    }

    func makeSelectorViewController(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController {
        UIHostingController(
            rootView: makeSelectorView(openAddCardFlow: openAddCardFlow, onComplete: onComplete)
        )
    }

    func makeSelectorView(
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> AnyView {
        let env = CardManagementEnvironment(
            accountModelProvider: accountModelProvider,
            cardIssuingBuilder: self,
            cardService: cardService,
            legalService: legalService,
            mainQueue: .main,
            productsService: productService,
            transactionService: transactionService,
            supportRouter: supportRouter,
            userInfoProvider: userInfoProvider,
            topUpRouter: topUpRouter,
            addressSearchRouter: addressSearchRouter,
            notificationCenter: NotificationCenter.default,
            openAddCardFlow: openAddCardFlow,
            close: onComplete
        )

        let store = Store<CardManagementState, CardManagementAction>(
            initialState: .init(
                isTokenisationEnabled: isEnabled(blockchain.app.configuration.card.issuing.tokenise.is.enabled),
                tokenisationCoordinator: PassTokenisationCoordinator(service: cardService)
            ),
            reducer: cardManagementReducer,
            environment: env
        )

        return AnyView(CardSelectorView(store: store, isModal: false))
    }
}
