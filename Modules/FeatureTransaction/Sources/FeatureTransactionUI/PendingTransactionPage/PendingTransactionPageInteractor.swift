// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift

protocol PendingTransactionPageRouting: Routing {}

protocol PendingTransactionPageListener: AnyObject {
    func pendingTransactionPageDidTapClose()
    func pendingTransactionPageDidTapComplete()
}

protocol PendingTransactionPagePresentable: Presentable, PendingTransactionPageViewControllable {
    func connect(state: Driver<PendingTransactionPageState>) -> Driver<PendingTransactionPageState.Effect>
}

final class PendingTransactionPageInteractor: PresentableInteractor<PendingTransactionPagePresentable>, PendingTransactionPageInteractable {

    weak var router: ViewableRouter<Interactable, ViewControllable>?
    weak var listener: PendingTransactionPageListener?

    private let pendingTransationStateProvider: PendingTransactionStateProviding
    private let transactionModel: TransactionModel

    init(
        transactionModel: TransactionModel,
        presenter: PendingTransactionPagePresentable,
        action: AssetAction
    ) {
        self.pendingTransationStateProvider = PendingTransctionStateProviderFactory.pendingTransactionStateProvider(
            action: action
        )
        self.transactionModel = transactionModel
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let state: Driver<PendingTransactionPageState> = pendingTransationStateProvider
            .connect(state: transactionModel.state)
            .asDriver(onErrorJustReturn: .empty)

        presenter
            .connect(state: state)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func handle(effect: PendingTransactionPageState.Effect) {
        switch effect {
        case .close:
            listener?.pendingTransactionPageDidTapClose()
        case .complete:
            listener?.pendingTransactionPageDidTapComplete()
        case .none:
            break
        }
    }

    override func willResignActive() {
        super.willResignActive()
    }
}
