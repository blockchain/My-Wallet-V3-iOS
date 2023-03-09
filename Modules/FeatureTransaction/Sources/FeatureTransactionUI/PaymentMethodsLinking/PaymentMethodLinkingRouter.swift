// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeaturePlaidUI
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit
import UIKit

public enum PaymentMethodsLinkingFlowResult: Equatable {
    case abandoned
    case completed(PaymentMethod?)

    public var isCompleted: Bool {
        switch self {
        case .completed:
            return true
        case .abandoned:
            return false
        }
    }
}

/// Use this protocol to present the end-to-end payment method linking flow (where the user selects which payment method to link among their linkable payment methods) and links it.
/// This protocol also provides methods to present each individual payment method linking flow directly, by-passing the selection screen.
public protocol PaymentMethodLinkingRouterAPI {

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

extension PaymentMethodLinkingRouterAPI {

    /// Presents a screen where the user can select a linkable payment method among a list of eligible payment methods.
    /// The user is then redirected to a flow to actually link the selected payment method.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    public func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        routeToPaymentMethodLinkingFlow(from: viewController, filter: { _ in true }, completion: completion)
    }
}

final class PaymentMethodLinkingRouter: PaymentMethodLinkingRouterAPI {

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let paymentMethodsLinker: PaymentMethodLinkingSelectorAPI
    private let bankAccountLinker: BankAccountLinkerAPI
    private let bankWireLinker: BankWireLinkerAPI
    private let cardLinker: CardLinkerAPI
    private let app: AppProtocol

    private var cancellables = Set<AnyCancellable>()
    private var cardLinkingCancellables = Set<AnyCancellable>()

    init(
        app: AppProtocol = DIKit.resolve(),
        featureFlagsService: FeatureFlagsServiceAPI,
        paymentMethodsLinker: PaymentMethodLinkingSelectorAPI = PaymentMethodLinkingSelector(),
        bankAccountLinker: BankAccountLinkerAPI = BankAccountLinker(),
        bankWireLinker: BankWireLinkerAPI = BankWireLinker(),
        cardLinker: CardLinkerAPI = CardLinker()
    ) {
        self.app = app
        self.featureFlagsService = featureFlagsService
        self.paymentMethodsLinker = paymentMethodsLinker
        self.bankAccountLinker = bankAccountLinker
        self.bankWireLinker = bankWireLinker
        self.cardLinker = cardLinker
    }

    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        paymentMethodsLinker.presentAccountLinkingFlow(from: viewController, filter: filter) { [weak self] result in
            guard let self else { return }
            switch result {
            case .abandoned:
                completion(.abandoned)

            case .completed(let paymentMethod):
                // we have to dismiss here otherwise the implementation of present account linking flow
                // crashes on internal builds due to a RIB's memory leak.
                viewController.dismiss(animated: true) {
                    switch paymentMethod.type {
                    case .card:
                        self.routeToCardLinkingFlow(from: viewController, completion: completion)

                    case .applePay:
                        completion(.completed(paymentMethod))

                    case .bankTransfer:
                        self.routeToDirectBankLinkingFlow(from: viewController, completion: completion)

                    case .bankAccount:
                        self.routeToBankLinkingFlow(
                            for: paymentMethod.fiatCurrency,
                            from: viewController,
                            completion: completion
                        )

                    case .funds(let data):
                        self.routeToWiringInstructionsFlow(
                            for: data.fiatCurrency ?? .locale,
                            from: viewController,
                            completion: completion
                        )
                    }
                }
            }
        }
    }

    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link.card)
        if isVGSEnabledOrUserHasCassyTagOnAlpha(app) {
            // any previous observations need to be killed...
            cardLinkingCancellables = []
            app.on(blockchain.ux.payment.method.vgs.add.card.abandoned)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    completion(.abandoned)
                }
                .store(in: &cardLinkingCancellables)

            app.on(blockchain.ux.payment.method.vgs.add.card.completed)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    completion(.completed(nil))
                }
                .store(in: &cardLinkingCancellables)
            Task(priority: .userInitiated) { [app] in
                // we need to clear any values set to the following `Tag.Event`
                // as the close of the modal is handled differently here
                try await app.set(
                    blockchain.ux.payment.method.vgs.add.card.abandoned.then.close,
                    to: nil
                )
                try await app.set(
                    blockchain.ux.payment.method.vgs.add.card.completed.then.close,
                    to: nil
                )
                app.post(event: blockchain.ux.payment.method.vgs.add.card)
            }
        } else {
            cardLinker.presentCardLinkingFlow(from: viewController) { result in
                let flowResult: PaymentMethodsLinkingFlowResult = result == .abandoned ? .abandoned : .completed(nil)
                completion(flowResult)
            }
        }
    }

    func routeToBankLinkingFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link.bank)
        switch currency {
        case .USD, .ARS, .BRL:
            routeToDirectBankLinkingFlow(from: viewController, completion: completion)
        case .GBP, .EUR:
            featureFlagsService
                .isEnabled(.openBanking)
                .if(
                    then: { [weak self] in
                        self?.routeToDirectBankLinkingFlow(from: viewController, completion: completion)
                    },
                    else: { [weak self] in
                        self?.routeToWiringInstructionsFlow(
                            for: currency,
                            from: viewController,
                            completion: completion
                        )
                    }
                )
                .store(in: &cancellables)
        default:
            routeToWiringInstructionsFlow(
                for: currency,
                from: viewController,
                completion: completion
            )
        }
    }

    func routeToBankWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        app.post(event: blockchain.ux.payment.method.link.bank.wire)
        routeToWiringInstructionsFlow(for: currency, from: viewController, completion: completion)
    }

    private func routeToDirectBankLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        if app.state.yes(if: blockchain.ux.payment.method.plaid.is.available) {
            showLinkBankFlowWithPlaid(from: viewController, completion: completion)
        } else {
            bankAccountLinker.presentBankLinkingFlow(from: viewController) { result in
                completion(result == .abandoned ? .abandoned : .completed(nil))
            }
        }
    }

    private func showLinkBankFlowWithPlaid(
        from presenter: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        let app: AppProtocol = DIKit.resolve()
        let view = PlaidView(store: .init(
            initialState: PlaidState(),
            reducer: PlaidModule.reducer,
            environment: .init(
                app: app,
                mainQueue: .main,
                plaidRepository: DIKit.resolve(),
                dismissFlow: { success in
                    completion(success ? .completed(nil) : .abandoned)
                }
            )
        )).app(app)

        let viewController = UIHostingController(rootView: view)
        viewController.isModalInPresentation = true
        DispatchQueue.main.async {
            presenter.present(viewController, animated: false)
        }
    }

    private func routeToWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        bankWireLinker.presentBankWireInstructions(from: viewController) {
            completion(.abandoned) // cannot end any other way
        }
    }
}

/// a mouthful of a method
func isVGSEnabledOrUserHasCassyTagOnAlpha(_ app: AppProtocol) -> Bool {
    if app.remoteConfiguration.yes(if: blockchain.ux.payment.method.vgs.is.enabled) {
        return true
    } else if BuildFlag.isAlpha {
        return (try? app.state.get(blockchain.user.is.cassy.card.alpha)) ?? false
    }
    return false
}
