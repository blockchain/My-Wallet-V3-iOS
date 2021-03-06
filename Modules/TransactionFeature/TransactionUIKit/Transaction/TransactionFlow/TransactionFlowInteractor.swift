// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxRelay
import RxSwift
import ToolKit

protocol TransactionFlowRouting: Routing {
    func pop()
    func closeFlow()
    func showFailure()
    func didTapBack()
    func routeToConfirmation(transactionModel: TransactionModel)
    func routeToTargetSelectionPicker(transactionModel: TransactionModel, action: AssetAction)
    func routeToDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction)
    func routeToInProgress(transactionModel: TransactionModel, action: AssetAction)
    func routeToPriceInput(source: BlockchainAccount, transactionModel: TransactionModel, action: AssetAction)
    func routeToSourceAccountPicker(transactionModel: TransactionModel, action: AssetAction)
}

protocol TransactionFlowListener: AnyObject {
    func presentKYCTiersScreen()
    func dismissTransactionFlow()
}

final class TransactionFlowInteractor: PresentableInteractor<TransactionFlowPresentable>,
                                       TransactionFlowInteractable,
                                       AccountPickerListener,
                                       TransactionFlowPresentableListener,
                                       TargetSelectionPageListener {

    weak var router: TransactionFlowRouting?
    weak var listener: TransactionFlowListener?
    private var initialStep: Bool = true
    private let transactionModel: TransactionModel
    private let action: AssetAction
    private let sourceAccount: BlockchainAccount?
    private let target: TransactionTarget?
    private let analyticsHook: TransactionAnalyticsHook

    init(transactionModel: TransactionModel,
         action: AssetAction,
         sourceAccount: BlockchainAccount?,
         target: TransactionTarget?,
         presenter: TransactionFlowPresentable,
         analyticsHook: TransactionAnalyticsHook = resolve()) {
        self.transactionModel = transactionModel
        self.action = action
        self.sourceAccount = sourceAccount
        self.target = target
        self.analyticsHook = analyticsHook
        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        transactionModel.destroy()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        transactionModel
            .state
            .distinctUntilChanged(\.step)
            .observeOn((MainScheduler.asyncInstance))
            .subscribe { [weak self] state in
                self?.handleStateChange(newState: state)
            }
            .disposeOnDeactivate(interactor: self)

        let requireSecondPassword: Single<Bool> = sourceAccount?.requireSecondPassword ?? .just(false)

        requireSecondPassword
            .observeOn(MainScheduler.asyncInstance)
            .map { [sourceAccount, target, action] passwordRequired -> TransactionAction in
                if action == .deposit {
                    return self.handleFiatDeposit(
                        sourceAccount: sourceAccount,
                        target: target,
                        passwordRequired: passwordRequired
                    )
                }
                guard let sourceAccount = sourceAccount else {
                    return .initialiseWithNoSourceOrTargetAccount(
                        action: action,
                        passwordRequired: passwordRequired
                    )
                }
                guard let target = target else {
                    return .initialiseWithSourceAccount(
                        action: action,
                        sourceAccount: sourceAccount,
                        passwordRequired: passwordRequired
                    )
                }
                switch action {
                case .swap:
                    return .initialiseWithSourceAndPreferredTarget(
                        action: action,
                        sourceAccount: sourceAccount,
                        target: target,
                        passwordRequired: passwordRequired
                    )
                default:
                    return .initialiseWithSourceAndTargetAccount(
                        action: action,
                        sourceAccount: sourceAccount,
                        target: target,
                        passwordRequired: passwordRequired
                    )
                }
            }
            .subscribe(
                onSuccess: { [weak self] action in
                    self?.transactionModel.process(action: action)
                },
                onError: { [weak self] error in
                    Logger.shared.debug("Unable to configure transaction flow, aborting. \(String(describing: error))")
                    self?.finishFlow()
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func didSelect(blockchainAccount: BlockchainAccount) {
        guard let target = blockchainAccount as? TransactionTarget else {
            fatalError("Account \(blockchainAccount.self) is not currently supported.")
        }
        didSelect(target: target)
    }

    func didSelect(target: TransactionTarget) {
        transactionModel.state
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [weak self] state in
                switch state.step {
                case .selectSource:
                    /// Apply the source account
                    self?.didSelectSourceAccount(account: target as! BlockchainAccount)
                    /// If the flow was started with a destination already, like if they
                    /// are depositing into a `FiatAccount`, we apply the destination.
                    /// This will route the user to the `Enter Amount` screen.
                    if let destination = state.destination {
                        self?.didSelectDestinationAccount(target: destination)
                    }
                case .selectTarget:
                    self?.didSelectDestinationAccount(target: target)
                    if let selectedSource = state.source as? CryptoAccount,
                       let target = target as? CryptoAccount {
                        self?.analyticsHook.onReceiveAccountSelected(selectedSource,
                                                                     target: target,
                                                                     action: state.action)
                    }

                default:
                    break
                }
            })
            .disposeOnDeactivate(interactor: self)
    }

    func didTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func didTapClose() {
        router?.closeFlow()
        analyticsHook.onClose(action: action)
    }

    func enterAmountDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func closeFlow() {
        transactionModel.process(action: .resetFlow)
        router?.closeFlow()
        analyticsHook.onClose(action: action)
    }

    func checkoutDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func didSelectSourceAccount(account: BlockchainAccount) {
        analyticsHook.onFromAccountSelected(account, action: action)
        transactionModel.process(action: .sourceAccountSelected(account))
    }

    func didSelectDestinationAccount(target: TransactionTarget) {
        transactionModel.process(action: .targetAccountSelected(target))
    }

    func didConfirmTransaction() {
        transactionModel.process(action: .executeTransaction)
    }

    func continueToKYCTiersScreen() {
        listener?.presentKYCTiersScreen()
    }

    func showGenericFailure() {
        router?.showFailure()
    }

    // MARK: - Private Functions

    private func handleStateChange(newState: TransactionState) {
        if !initialStep, newState.step == TransactionStep.initial {
            finishFlow()
        } else {
            initialStep = false
            showFlowStep(newState: newState)
            analyticsHook.onStepChanged(newState)
        }
    }

    private func finishFlow() {
        transactionModel.process(action: .resetFlow)
    }

    private func showFlowStep(newState: TransactionState) {
        guard !newState.isGoingBack else {
            router?.didTapBack()
            return
        }
        switch newState.step {
        case .initial:
            break
        case .enterAmount:
            router?.routeToPriceInput(source: newState.source!, transactionModel: transactionModel, action: action)
        case .enterPassword:
            unimplemented()
        case .selectTarget:
            /// `TargetSelectionViewController` should only be shown for `SendP2`
            /// and `.send`. Otherwise we should show the account picker to select
            /// the destination/target.
            if action == .send {
                router?.routeToTargetSelectionPicker(transactionModel: transactionModel, action: action)
                return
            }
            router?.routeToDestinationAccountPicker(transactionModel: transactionModel, action: action)
        case .confirmDetail:
            router?.routeToConfirmation(transactionModel: transactionModel)
        case .inProgress:
            router?.routeToInProgress(transactionModel: transactionModel, action: action)
        case .selectSource:
            router?.routeToSourceAccountPicker(transactionModel: transactionModel, action: action)
        case .enterAddress:
            router?.routeToDestinationAccountPicker(transactionModel: transactionModel, action: action)
        case .closed:
            transactionModel.destroy()
        }
    }

    private func handleFiatDeposit(sourceAccount: BlockchainAccount?, target: TransactionTarget?, passwordRequired: Bool) -> TransactionAction {
        if let source = sourceAccount, let target = target {
            return .initialiseWithSourceAndTargetAccount(action: .deposit, sourceAccount: source, target: target, passwordRequired: passwordRequired)
        }
        if let source = sourceAccount {
            return .initialiseWithSourceAccount(action: .deposit, sourceAccount: source, passwordRequired: passwordRequired)
        }
        if let target = target {
            return .initialiseWithTargetAndNoSource(action: .deposit, target: target, passwordRequired: passwordRequired)
        } else {
            return .initialiseWithNoSourceOrTargetAccount(action: .deposit, passwordRequired: passwordRequired)
        }
    }
}
