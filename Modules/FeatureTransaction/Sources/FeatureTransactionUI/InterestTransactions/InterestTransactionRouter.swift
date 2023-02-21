// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import ToolKit
import UIComponentsKit

protocol InterestTransactionInteractable: Interactable, TransactionFlowListener {
    var router: InterestTransactionRouting? { get set }
    var listener: InterestTransactionListener? { get set }
}

final class InterestTransactionRouter: RIBs.Router<InterestTransactionInteractable>, InterestTransactionRouting {

    // MARK: - Private Properties

    private var transactionRouter: ViewableRouting?
    private var paymentMethodRouter: ViewableRouting?
    private let topMostViewControllerProviding: TopMostViewControllerProviding
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Init

    init(
        interactor: InterestTransactionInteractable,
        topMostViewControllerProviding: TopMostViewControllerProviding = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
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

    func startWithdraw(target: CryptoTradingAccount, sourceAccount: CryptoInterestAccount) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .interestWithdraw,
            sourceAccount: sourceAccount,
            target: target
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
            analyticsRecorder.record(
                event: .interestWithdrawalViewed(
                    currency: sourceAccount.currencyType.code
                )
            )
        }
    }

    func startTransfer(target: CryptoInterestAccount, sourceAccount: CryptoAccount?) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .interestTransfer,
            sourceAccount: sourceAccount,
            target: target
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
            analyticsRecorder.record(
                event: .interestDepositViewed(
                    currency: target.currencyType.code
                )
            )
        }
    }

    func startDeposit(target: CryptoStakingAccount, sourceAccount: CryptoAccount?) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .stakingDeposit,
            sourceAccount: sourceAccount,
            target: target
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
        }
    }

    func startWithdraw(sourceAccount: CryptoActiveRewardsAccount) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .activeRewardsWithdraw,
            sourceAccount: sourceAccount,
            target: nil
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
        }
    }

    func startDeposit(target: CryptoActiveRewardsAccount, sourceAccount: CryptoAccount?) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .activeRewardsDeposit,
            sourceAccount: sourceAccount,
            target: target
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable.uiviewController
            attachChild(router)
            present(viewController: viewControllable)
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

    private func present(viewController: UIViewController) {
        guard let topViewController = topMostViewControllerProviding.topMostViewController else {
            fatalError("Expected a ViewController")
        }
        guard viewController is UINavigationController == false else {
            topViewController.present(viewController, animated: true, completion: nil)
            return
        }
        let navController = UINavigationController(rootViewController: viewController)
        topViewController.present(navController, animated: true, completion: nil)
    }

    private func dismissTopMost(
        weak object: InterestTransactionRouter,
        _ selector: @escaping (InterestTransactionRouter) -> Void
    ) {
        guard let viewController = topMostViewControllerProviding.topMostViewController else {
            selector(object)
            return
        }
        viewController.dismiss(animated: true, completion: {
            selector(object)
        })
    }
}
