// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureKYCUI
import FeatureSettingsUI
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import UIKit

protocol PaymentMethodsLinkingAdapterAPI {

    /// Presents a screen where the user can select a linkable payment method among a list of eligible payment methods.
    /// The user is then redirected to a flow to actually link the selected payment method.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )

    /// Presents the flow to link a credit or debit card to the user's account.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )

    /// Presents the flow to link a bank account to the user's account via Open Banking or ACH.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToBankLinkingFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )

    /// Presents the flow to link a bank account to the user's account via Open Banking or ACH.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToBankWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )
}

extension PaymentMethodsLinkingAdapterAPI {

    /// Presents a screen where the user can select a linkable payment method among a list of eligible payment methods.
    /// The user is then redirected to a flow to actually link the selected payment method.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        routeToPaymentMethodLinkingFlow(from: viewController, filter: { _ in true }, completion: completion)
    }
}

final class PaymentMethodsLinkingAdapter: PaymentMethodsLinkingAdapterAPI {

    private let app: AppProtocol
    private let router: PaymentMethodLinkingRouterAPI
    private let kycRouter: FeatureKYCUI.Routing

    private var bag: Set<AnyCancellable> = []

    init(
        app: AppProtocol = resolve(),
        router: FeatureTransactionUI.PaymentMethodLinkingRouterAPI = resolve(),
        kycRouter: FeatureKYCUI.Routing = resolve()
    ) {
        self.app = app
        self.router = router
        self.kycRouter = kycRouter
    }

    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link)
        kyc(presenter: viewController) { [router] result in
            switch result {
            case .abandoned:
                completion(.abandoned)
            case .completed, .skipped:
                router.routeToPaymentMethodLinkingFlow(from: viewController, filter: filter, completion: completion)
            }
        }
    }

    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link.card)
        kyc(presenter: viewController) { [router] result in
            switch result {
            case .abandoned:
                completion(.abandoned)
            case .completed, .skipped:
                router.routeToCardLinkingFlow(from: viewController, completion: completion)
            }
        }
    }

    func routeToBankLinkingFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link.bank)
        kyc(presenter: viewController) { [router] result in
            switch result {
            case .abandoned:
                completion(.abandoned)
            case .completed, .skipped:
                router.routeToBankLinkingFlow(for: currency, from: viewController, completion: completion)
            }
        }
    }

    /// Presents the flow to link a bank account to the user's account via Open Banking or ACH.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToBankWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link.bank.wire)
        kyc(presenter: viewController) { [router] result in
            switch result {
            case .abandoned:
                completion(.abandoned)
            case .completed, .skipped:
                router.routeToBankWiringInstructionsFlow(for: currency, from: viewController, completion: completion)
            }
        }
    }

    private func kyc(
        presenter viewController: UIViewController,
        then completion: @escaping (FlowResult) -> Void
    ) {
        kycRouter.presentKYCIfNeeded(from: viewController, requiredTier: .verified)
            .sink(receiveValue: completion)
            .store(in: &bag)
    }
}

// MARK: - FeatureSettingsUI.PaymentMethodsLinkerAPI

extension PaymentMethodsLinkingAdapter: FeatureSettingsUI.PaymentMethodsLinkerAPI {

    func routeToBankLinkingFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        // Linking a bank from settings should give options to wire funds or link a bank directly
        routeToPaymentMethodLinkingFlow(
            from: viewController,
            filter: { type in
                type.method.isFunds || type.method.isBankTransfer
            },
            completion: { _ in
                completion()
            }
        )
    }

    func routeToCardLinkingFlow(from viewController: UIViewController, completion: @escaping () -> Void) {
        routeToCardLinkingFlow(from: viewController) { _ in
            completion()
        }
    }
}
