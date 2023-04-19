// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift

enum NetworkFeeSelectionEffects {
    case selectedFee(FeeLevel)
    case okTapped
    case none
}

protocol NetworkFeeSelectionRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NetworkFeeSelectionPresentable: Presentable {
    var listener: NetworkFeeSelectionPresentableListener? { get set }

    func connect(state: Driver<NetworkFeeSelectionInteractor.State>) -> Driver<NetworkFeeSelectionEffects>
}

protocol NetworkFeeSelectionListener: AnyObject {
    func dismissNetworkFeeSelectionScreen()
}

final class NetworkFeeSelectionInteractor: PresentableInteractor<NetworkFeeSelectionPresentable>,
    NetworkFeeSelectionInteractable,
    NetworkFeeSelectionPresentableListener
{

    weak var router: NetworkFeeSelectionRouting?
    weak var listener: NetworkFeeSelectionListener?

    private let transactionModel: TransactionModel

    init(
        presenter: NetworkFeeSelectionPresentable,
        transactionModel: TransactionModel
    ) {
        self.transactionModel = transactionModel
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let transactionState: Observable<TransactionState> = transactionModel
            .state
            .share(replay: 1, scope: .whileConnected)

        // Depending on the `FeeState` we may need to show an error
        // in the custom fee entry cell.
        //  let feeState = transactionState
        //      .map(\.feeSelection)
        //      .compactMap(\.feeState)

        let state = transactionState
            .scan(.initial) { [weak self] state, updater -> State in
                guard let self else { return state }
                return calculateNextState(with: state, updater: updater)
            }
            .asDriverCatchError()

        presenter.connect(state: state)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func calculateNextState(
        with state: State,
        updater: TransactionState
    ) -> State {
        state
            .update(keyPath: \.selectedFeeLevel, value: updater.feeSelection.selectedLevel)
            .update(keyPath: \.okButtonEnabled, value: true)
    }

    private func handle(effect: NetworkFeeSelectionEffects) {
        switch effect {
        case .okTapped:
            listener?.dismissNetworkFeeSelectionScreen()
        case .none:
            break
        case .selectedFee(let feeLevel):
            transactionModel.process(action: .updateFeeLevelAndAmount(feeLevel, nil))
        }
    }
}

extension NetworkFeeSelectionInteractor {
    struct State: StateType {
        var selectedFeeLevel: FeeLevel
        var okButtonEnabled: Bool

        static let initial: State = .init(selectedFeeLevel: .none, okButtonEnabled: false)
    }
}
