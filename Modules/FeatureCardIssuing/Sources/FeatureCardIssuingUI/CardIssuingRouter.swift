// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import Errors
import Extensions
import FeatureCardIssuingDomain
import SwiftUI
import UIKit

public protocol CardIssuingRouterAPI: AnyObject {
    func open(
        with navigationController: NavigationControllerAPI
    )
}

public protocol NavigationControllerAPI: AnyObject {
    func pushViewController(_ viewController: UIViewController, animated: Bool)

    @discardableResult
    func popViewController(animated: Bool) -> UIViewController?
    func popToRootViewControllerAnimated(animated: Bool)
}

public protocol AddressProviderAPI: AnyObject {
    var address: AnyPublisher<Card.Address, CardOrderingError> { get }
}

final class CardIssuingRouter: CardIssuingRouterAPI {
    private var navigationController: NavigationControllerAPI?
    private let builder: CardIssuingBuilderAPI
    private let addressProvider: AddressProviderAPI
    private let cardService: CardServiceAPI
    private let kycService: KYCServiceAPI
    private let productService: ProductsServiceAPI
    private var cancellables: Set<AnyCancellable> = []

    init(
        builder: CardIssuingBuilderAPI,
        addressProvider: AddressProviderAPI,
        cardService: CardServiceAPI,
        kycService: KYCServiceAPI,
        productService: ProductsServiceAPI
    ) {
        self.builder = builder
        self.addressProvider = addressProvider
        self.cardService = cardService
        self.kycService = kycService
        self.productService = productService
    }

    func open(
        with navigationController: NavigationControllerAPI
    ) {
        open(with: navigationController, card: nil)
    }

    func open(
        with navigationController: NavigationControllerAPI,
        card: Card?
    ) {
        self.navigationController = navigationController
        Publishers.CombineLatest3(
            kycService.fetch()
                .replaceError(with: .init(status: .unverified, errorFields: nil))
                .setFailureType(to: NabuNetworkError.self),
            cardService.fetchCards(),
            productService.fetchProducts()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] kyc, cards, products in
            if products.isNotEmpty, cards.isEmpty || kyc.status == .pending || kyc.status == .failure {
                self?.openIntroFlow()
            } else if let card = card {
                self?.openCardManagementFlow([card])
            } else if cards.isNotEmpty {
                self?.openCardManagementFlow(cards)
            }
        }
        .store(in: &cancellables)
    }

    func openIntroFlow() {
        guard let navigationController else {
            return
        }

        kycService
            .fetch()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] kyc in
                guard let self else {
                    return
                }
                navigationController.pushViewController(
                    self.builder.makeIntroViewController(
                        address: self.addressProvider.address,
                        kyc: kyc,
                        onComplete: { [weak self] result in
                            navigationController.popToRootViewControllerAnimated(animated: true)
                            switch result {
                            case .created(let card):
                                self?.open(with: navigationController, card: card)
                            case .cancelled:
                                break
                            case .kyc:
                                self?.open(with: navigationController)
                            }
                        }
                    ),
                    animated: true
                )
            }
            .store(in: &cancellables)
    }

    func openCardManagementFlow(_ cards: [Card]) {
        guard let navigationController else {
            return
        }

        if cards.count == 1,
           let card = cards.first,
           card.status != .initiated
        {
            navigationController.pushViewController(
                builder.makeManagementViewController(
                    selectedCard: card,
                    openAddCardFlow: { [weak self] in
                        navigationController.popToRootViewControllerAnimated(animated: true)
                        self?.openIntroFlow()
                    },
                    onComplete: {
                        navigationController.popToRootViewControllerAnimated(animated: true)
                    }
                ),
                animated: true
            )
        } else {
            navigationController.pushViewController(
                builder.makeSelectorViewController(
                    openAddCardFlow: { [weak self] in
                        navigationController.popToRootViewControllerAnimated(animated: true)
                        self?.openIntroFlow()
                    },
                    onComplete: {
                        navigationController.popToRootViewControllerAnimated(animated: true)
                    }
                ),
                animated: true
            )
        }
    }
}
