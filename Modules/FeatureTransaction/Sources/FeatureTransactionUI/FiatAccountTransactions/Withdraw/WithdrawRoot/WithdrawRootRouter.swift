// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit
import UIComponentsKit

protocol WithdrawRootInteractable: Interactable,
    TransactionFlowListener,
    AddNewBankAccountListener,
    PaymentMethodListener
{
    var router: WithdrawRootRouting? { get set }
    var listener: WithdrawRootListener? { get set }

    func bankLinkingComplete()
    func bankLinkingClosed(isInteractive: Bool)
}

final class WithdrawRootRouter: RIBs.Router<WithdrawRootInteractable>, WithdrawRootRouting {

    // MARK: - Private Properties

    private let app: AppProtocol
    private var transactionRouter: ViewableRouting?
    private var paymentMethodRouter: ViewableRouting?
    private var linkBankFlowRouter: LinkBankFlowStarter?
    private let topMostViewControllerProviding: TopMostViewControllerProviding
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        app: AppProtocol = resolve(),
        interactor: WithdrawRootInteractable,
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

    // MARK: - WithdrawRootRouting

    func startWithLinkABank() {
        showLinkBankFlow()
    }

    func routeToLinkABank() {
        dismissTopMost(weak: self) { (self) in
            self.showLinkBankFlow()
        }
    }

    func startWithWireInstructions(currency: FiatCurrency) {
        showWireTransferScreen(fiatCurrency: currency)
    }

    func routeToWireInstructions(currency: FiatCurrency) {
        dismissTopMost(weak: self) { (self) in
            self.showWireTransferScreen(fiatCurrency: currency)
        }
    }

    func routeToAddABank() {
        let builder = PaymentMethodBuilder()
        paymentMethodRouter = builder.build(withListener: interactor)
        if let router = paymentMethodRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
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

    func dismissTransactionFlow() {
        guard let router = transactionRouter else { return }
        detachChild(router)
        transactionRouter = nil
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

    func startWithdraw(sourceAccount: FiatAccount, destination: LinkedBankAccount?) {
        showWithdrawFlow(sourceAccount: sourceAccount, destination: destination)
    }

    func routeToWithdraw(sourceAccount: FiatAccount, destination: LinkedBankAccount?) {
        dismissTopMost(weak: self) { (self) in
            self.showWithdrawFlow(sourceAccount: sourceAccount, destination: destination)
        }
    }

    // MARK: - Private Functions

    private func showWithdrawFlow(sourceAccount: FiatAccount, destination: LinkedBankAccount?) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .withdraw,
            sourceAccount: sourceAccount,
            target: destination
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
        }
    }

    private func showWireTransferScreen(fiatCurrency: FiatCurrency) {

        if app.remoteConfiguration.result(for: blockchain.app.configuration.wire.transfer[fiatCurrency.code].is.enabled).value as? Bool == true {
            Task {
                app.state.set(blockchain.api.nabu.gateway.payments.accounts.simple.buy.id, to: fiatCurrency.code)
                app.post(
                    action: blockchain.ux.payment.method.wire.transfer.entry.paragraph.row.tap.then.enter.into,
                    value: blockchain.ux.payment.method.wire.transfer
                )
            }
            return
        }

        let builder = AddNewBankAccountBuilder(currency: fiatCurrency, isOriginDeposit: false)
        let addNewBankRouter = builder.build(listener: interactor)
        let viewControllable = addNewBankRouter.viewControllable.uiviewController
        attachChild(addNewBankRouter)
        present(viewController: viewControllable)
    }

    // MARK: - Private methods

    private func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
    }

    private func showLinkBankFlow() {
        let builder = LinkBankFlowRootBuilder()
        let router = builder.build()
        linkBankFlowRouter = router
        analyticsRecorder.record(event: AnalyticsEvents.New.Withdrawal.linkBankClicked(origin: .withdraw))
        router.startFlow()
            .subscribe(onNext: { [weak self] effect in
                guard let self else { return }
                switch effect {
                case .closeFlow(let isInteractive):
                    self.interactor.bankLinkingClosed(isInteractive: isInteractive)
                case .bankLinked:
                    self.interactor.bankLinkingComplete()
                }
            })
            .disposed(by: disposeBag)
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

    private func dismissTopMost(weak object: WithdrawRootRouter, _ selector: @escaping (WithdrawRootRouter) -> Void) {
        guard let viewController = topMostViewControllerProviding.topMostViewController else {
            selector(object)
            return
        }
        viewController.dismiss(animated: true, completion: {
            selector(object)
        })
    }
}
