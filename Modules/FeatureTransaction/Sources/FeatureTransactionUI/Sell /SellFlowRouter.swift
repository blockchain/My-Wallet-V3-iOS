// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

protocol SellFlowRouting: Routing {
    func start(with currency: CryptoAccount?, from presenter: UIViewController)
    func start(with currency: CryptoAccount?, target: TransactionTarget?, from presenter: UIViewController)
}

extension SellFlowRouting {
    func start(with currency: CryptoAccount?, from presenter: UIViewController) {
        start(with: currency, target: nil, from: presenter)
    }
}

final class SellFlowRouter: RIBs.Router<SellFlowInteractor>, SellFlowRouting {

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let alertPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private var cancellables = Set<AnyCancellable>()

    init(
        interactor: SellFlowInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        alertPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
        super.init(interactor: interactor)
    }

    func start(with currency: CryptoAccount?, target: TransactionTarget?, from presenter: UIViewController) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .sell,
            sourceAccount: currency,
            target: target
        )
        attachChild(router)
        let viewController = router.viewControllable.uiviewController
        presenter.present(viewController, animated: true)
        interactor.presentKYCFlowIfNeeded(from: viewController) { completed in
            if !completed {
                presenter.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func dismissLoadingView() {
        loadingViewPresenter.hide()
    }

    private func presentLoadingView() {
        loadingViewPresenter.showCircular()
    }

    private func presentError(error: Error, from presenter: UIViewController) {
        alertPresenter.notify(
            content: .init(
                title: LocalizationConstants.Errors.genericError,
                message: String(describing: error)
            ),
            in: presenter
        )
    }
}
