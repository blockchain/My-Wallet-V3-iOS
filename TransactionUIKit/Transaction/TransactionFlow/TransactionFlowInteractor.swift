//
//  TransactionFlowInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 19/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
    func routeToInProgress(transactionModel: TransactionModel)
    func routeToPriceInput(source: BlockchainAccount, transactionModel: TransactionModel, action: AssetAction)
    func routeToSourceAccountPicker(action: AssetAction)
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
    private let transactionModel: TransactionModel
    private let action: AssetAction
    private let sourceAccount: CryptoAccount?
    private let target: TransactionTarget?
    private let analyticsHook: TransactionAnalyticsHook
    private let internalFeatureService: InternalFeatureFlagServiceAPI
    private let featureConfiguring: FeatureConfiguring

    init(transactionModel: TransactionModel,
         action: AssetAction,
         sourceAccount: CryptoAccount?,
         target: TransactionTarget?,
         presenter: TransactionFlowPresentable,
         internalFeatureService: InternalFeatureFlagServiceAPI = resolve(),
         featureConfiguring: FeatureConfiguring = resolve(),
         analyticsHook: TransactionAnalyticsHook = resolve()) {
        self.featureConfiguring = featureConfiguring
        self.transactionModel = transactionModel
        self.action = action
        self.sourceAccount = sourceAccount
        self.target = target
        self.internalFeatureService = internalFeatureService
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
            .map(weak: self) { [sourceAccount, target, action] (self, passwordRequired) -> TransactionAction in
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
                    Logger.shared.debug("Unable to configure transaction flow, aborting. \(error.localizedDescription)")
                    self?.finishFlow()
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func didSelect(blockchainAccount: BlockchainAccount) {
        transactionModel.state
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [weak self] state in
                switch state.step {
                case .selectSource:
                    self?.didSelectSourceAccount(account: blockchainAccount as! CryptoAccount)
                case .selectTarget:
                    let selectedSource = state.source!
                    let selectedTarget = blockchainAccount as! TransactionTarget
                    self?.didSelectDestinationAccount(target: selectedTarget)
                    self?.analyticsHook.onPairConfirmed(selectedSource.currencyType, target: selectedTarget)
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
        analyticsHook.onClose()
    }

    func enterAmountDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func closeFlow() {
        router?.closeFlow()
        analyticsHook.onClose()
    }

    func checkoutDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }
    
    func didSelectSourceAccount(account: CryptoAccount) {
        analyticsHook.onAccountSelected(account.currencyType)
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

    private var initialStep: Bool = true
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
            let internalSendEnabled = featureConfiguring.configuration(for: .internalSendEnabled).isEnabled
            if internalSendEnabled && action == .send {
                router?.routeToTargetSelectionPicker(transactionModel: transactionModel, action: action)
                return
            }
            router?.routeToDestinationAccountPicker(transactionModel: transactionModel, action: action)
        case .confirmDetail:
            router?.routeToConfirmation(transactionModel: transactionModel)
        case .inProgress:
            router?.routeToInProgress(transactionModel: transactionModel)
        case .selectSource:
            router?.routeToSourceAccountPicker(action: action)
        case .enterAddress:
            router?.routeToDestinationAccountPicker(transactionModel: transactionModel, action: action)
        case .closed:
            transactionModel.destroy()
        }
    }
}
