// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import DIKit
import FeaturePlaidUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import SwiftUI
import ToolKit
import UIComponentsKit

protocol DepositRootInteractable: Interactable,
    TransactionFlowListener,
    PaymentMethodListener,
    AddNewBankAccountListener
{

    var router: DepositRootRouting? { get set }
    var listener: DepositRootListener? { get set }

    func bankLinkingComplete()
    func bankLinkingClosed(isInteractive: Bool)
}

final class DepositRootRouter: RIBs.Router<DepositRootInteractable>, DepositRootRouting {

    // MARK: - Private Properties

    private var app: AppProtocol
    private var transactionRouter: ViewableRouting?
    private var paymentMethodRouter: ViewableRouting?
    private var linkBankFlowRouter: LinkBankFlowStarter?
    private let topMostViewControllerProviding: TopMostViewControllerProviding
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        app: AppProtocol = resolve(),
        interactor: DepositRootInteractable,
        topMostViewControllerProviding: TopMostViewControllerProviding = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.app = app
        self.topMostViewControllerProviding = topMostViewControllerProviding
        self.analyticsRecorder = analyticsRecorder
        super.init(interactor: interactor)
        interactor.router = self
    }

    // MARK: - Overrides

    override func didLoad() {
        super.didLoad()
        interactor.activate()
    }

    // MARK: - DepositRootRouting

    func routeToLinkABank() {
        dismissTopMost(weak: self) { (self) in
            self.showLinkBankFlow()
        }
    }

    func dismissBankLinkingFlow() {
        topMostViewControllerProviding
            .topMostViewController?
            .dismiss(animated: true, completion: nil)
        linkBankFlowRouter = nil
    }

    func dismissWireInstructionFlow() {
        detachCurrentChild()
        topMostViewControllerProviding
            .topMostViewController?
            .dismiss(animated: true, completion: nil)
    }

    func dismissPaymentMethodFlow() {
        if let router = paymentMethodRouter {
            detachChild(router)
            topMostViewControllerProviding
                .topMostViewController?
                .dismiss(animated: true, completion: nil)
            paymentMethodRouter = nil
        }
    }

    func startWithLinkABank() {
        showLinkBankFlow()
    }

    func startWithWireInstructions(currency: FiatCurrency) {
        showWireTransferScreen(fiatCurrency: currency)
    }

    func routeToWireInstructions(currency: FiatCurrency) {
        dismissTopMost(weak: self) { (self) in
            self.showWireTransferScreen(fiatCurrency: currency)
        }
    }

    func routeToDepositLanding() {
        let builder = PaymentMethodBuilder()
        paymentMethodRouter = builder.build(withListener: interactor)
        if let router = paymentMethodRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
        }
    }

    func startDeposit(target: FiatAccount, sourceAccount: LinkedBankAccount?) {
        showDepositFlow(target: target, sourceAccount: sourceAccount)
    }

    func routeToDeposit(target: FiatAccount, sourceAccount: LinkedBankAccount?) {
        dismissTopMost(weak: self) { (self) in
            self.showDepositFlow(target: target, sourceAccount: sourceAccount)
        }
    }

    func dismissTransactionFlow() {
        guard let router = transactionRouter else { return }
        detachChild(router)
        transactionRouter = nil
    }

    // MARK: - Private Functions

    private func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
    }

    private func showDepositFlow(target: FiatAccount, sourceAccount: LinkedBankAccount?) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .deposit,
            sourceAccount: sourceAccount,
            target: target
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
        }
    }

    private func showLinkBankFlow() {
        if app.state.yes(if: blockchain.ux.payment.method.plaid.is.available) {
            showLinkBankFlowWithPlaid()
        } else {
            showLinkBankFlowWithYodlee()
        }
    }

    private func showLinkBankFlowWithPlaid() {
        let router = Router<Interactor>(interactor: Interactor())
        attachChild(router)

        analyticsRecorder.record(event: AnalyticsEvents.New.Withdrawal.linkBankClicked(origin: .deposit))

        let app: AppProtocol = DIKit.resolve()
        let view = PlaidView(store: .init(
            initialState: PlaidState(),
            reducer: PlaidModule.reducer,
            environment: .init(
                app: app,
                mainQueue: .main,
                plaidRepository: DIKit.resolve(),
                dismissFlow: { [weak self] success in
                    guard let self else { return }
                    dismissBankLinkingFlow()
                    detachChild(router)
                    if success {
                        interactor.bankLinkingComplete()
                    } else {
                        interactor.bankLinkingClosed(isInteractive: true)
                    }
                }
            )
        )).app(app)

        let viewController = UIHostingController(rootView: view)
        viewController.isModalInPresentation = true
        DispatchQueue.main.async { [weak self] in
            self?.present(viewController: viewController)
        }
    }

    private func showLinkBankFlowWithYodlee() {
        let builder = LinkBankFlowRootBuilder()
        let router = builder.build()
        linkBankFlowRouter = router
        analyticsRecorder.record(event: AnalyticsEvents.New.Withdrawal.linkBankClicked(origin: .deposit))
        router.startFlow()
            .subscribe(onNext: { [weak self] effect in
                guard let self else { return }
                switch effect {
                case .closeFlow(let isInteractive):
                    interactor.bankLinkingClosed(isInteractive: isInteractive)
                case .bankLinked:
                    interactor.bankLinkingComplete()
                }
            })
            .disposed(by: disposeBag)
    }

    private func showWireTransferScreen(fiatCurrency: FiatCurrency) {
        let builder = AddNewBankAccountBuilder(currency: fiatCurrency, isOriginDeposit: false)
        let addNewBankRouter = builder.build(listener: interactor)
        let viewControllable = addNewBankRouter.viewControllable.uiviewController
        attachChild(addNewBankRouter)
        present(viewController: viewControllable)
    }

    private func present(viewController: UIViewController) {
        guard let topViewController = topMostViewControllerProviding.topMostViewController else {
            fatalError("Expected a ViewController")
        }
        guard topViewController is UINavigationController == false else {
            fatalError("Cannot present a `UINavigationController` over another.")
        }
        guard viewController is UINavigationController == false else {
            topViewController.present(viewController, animated: true, completion: nil)
            return
        }
        let navController = UINavigationController(rootViewController: viewController)
        topViewController.present(navController, animated: true, completion: nil)
    }

    private func dismissTopMost(weak object: DepositRootRouter, _ selector: @escaping (DepositRootRouter) -> Void) {
        guard let viewController = topMostViewControllerProviding.topMostViewController else {
            selector(object)
            return
        }
        viewController.dismiss(animated: true, completion: {
            selector(object)
        })
    }
}
