// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import PlatformUIKit
import RIBs
import ToolKit

protocol EnterAmountPageInteractable: Interactable {
    var router: EnterAmountPageRouting? { get set }
    var listener: EnterAmountPageListener? { get set }
}

protocol EnterAmountViewControllable: ViewControllable {}

final class EnterAmountPageRouter: ViewableRouter<EnterAmountPageInteractable, EnterAmountViewControllable>,
    EnterAmountPageRouting,
    NetworkFeeSelectionListener
{

    private let alertViewPresenter: AlertViewPresenterAPI

    init(
        interactor: EnterAmountPageInteractable,
        viewController: EnterAmountViewControllable,
        alertViewPresenter: AlertViewPresenterAPI = resolve()
    ) {
        self.alertViewPresenter = alertViewPresenter
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showError(_ error: Error) {
        Logger.shared.error(error)
        alertViewPresenter.error(in: viewController.uiviewController, action: nil)
    }

    func showFeeSelectionSheet(with transactionModel: TransactionModel) {
        let builder = NetworkFeeSelectionBuilder()
        let router = builder.build(withListener: self, transactionModel: transactionModel)
        let viewController = router.viewControllable.uiviewController
        viewController.transitioningDelegate = sheetPresenter
        viewController.modalPresentationStyle = .custom
        attachChild(router)
        self.viewController.uiviewController.present(viewController, animated: true, completion: nil)
    }

    func dismissNetworkFeeSelectionScreen() {
        detachCurrentChild()
    }

    private func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
        viewController.uiviewController.dismiss(animated: true, completion: nil)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = BottomSheetPresenting(ignoresBackgroundTouches: true)
}
