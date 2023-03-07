// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import ToolKit
import UIComponentsKit

public protocol SendRootRouting: ViewableRouting {
    /// Landing shows all wallets that the user can send from.
    func routeToSendLanding(navigationBarHidden: Bool)
    func routeToSend(sourceAccount: BlockchainAccount, destination: TransactionTarget?)
    func dismissTransactionFlow()
}

extension SendRootRouting {

    public func routeToSendLanding() {
        routeToSendLanding(navigationBarHidden: false)
    }

    public func routeToSend(sourceAccount: BlockchainAccount) {
        routeToSend(
            sourceAccount: sourceAccount,
            destination: nil
        )
    }
}

final class SendRootRouter: ViewableRouter<SendRootInteractable, SendRootViewControllable>, SendRootRouting {

    // MARK: - Types

    private typealias LocalizedSend = LocalizationConstants.Send

    // MARK: - Private Properties

    private var transactionRouter: ViewableRouting?
    private let analyticsHook: TransactionAnalyticsHook

    // MARK: - Init

    init(
        interactor: SendRootInteractable,
        viewController: SendRootViewControllable,
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.analyticsHook = analyticsHook
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - SwapRootRouting

    func routeToSendLanding(navigationBarHidden: Bool) {
        let header = AccountPickerHeaderModel(
            imageContent: .empty,
            switchable: true,
            subtitle: nil,
            title: LocalizedSend.Header.send
        )
        let navigationModel: ScreenNavigationModel?
        if !navigationBarHidden {
            navigationModel = ScreenNavigationModel(
                leadingButton: .drawer,
                trailingButton: .qrCode,
                titleViewStyle: .text(value: LocalizedSend.Text.send),
                barStyle: .lightContent()
            )
        } else {
            navigationModel = nil
        }
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: .send
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            guard let cryptoAccount = account as? CryptoAccount else {
                fatalError("Expected a CryptoAccount: \(account)")
            }
            self?.routeToSend(sourceAccount: cryptoAccount)
        }
        let sendAccountPickerRouter = builder.build(
            listener: .simple(didSelect),
            navigationModel: navigationModel,
            headerModel: .default(header),
            showWithdrawalLocks: true
        )
        attachChild(sendAccountPickerRouter)
        viewController.replaceRoot(
            viewController: sendAccountPickerRouter.viewControllable,
            animated: false
        )
    }

    func routeToSend(sourceAccount: BlockchainAccount, destination: TransactionTarget?) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .send,
            sourceAccount: sourceAccount,
            target: destination
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable
            attachChild(router)
            viewController.present(viewController: viewControllable)
        }
    }

    func dismissTransactionFlow() {
        guard let router = transactionRouter else { return }
        detachChild(router)
        transactionRouter = nil
    }
}
