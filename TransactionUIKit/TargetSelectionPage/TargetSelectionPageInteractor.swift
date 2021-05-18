//
//  TargetSelectionPageInteractor.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol TargetSelectionPageRouting: ViewableRouting {
}

protocol TargetSelectionPageListener: AnyObject {
    func didSelect(target: TransactionTarget)
    func didTapBack()
    func didTapClose()
}

final class TargetSelectionPageInteractor: PresentableInteractor<TargetSelectionPagePresentable>,
                                           TargetSelectionPageInteractable {

    weak var router: TargetSelectionPageRouting?

    // MARK: - Private Properties
    
    private let accountProvider: SourceAndTargetAccountProviding
    private let targetSelectionPageModel: TargetSelectionPageModel
    private let action: AssetAction
    private let cryptoAddressViewModel: CryptoAddressTextFieldViewModel
    private let messageRecorder: MessageRecording
    private let didSelect: AccountPickerDidSelect?
    weak var listener: TargetSelectionPageListener?

    // MARK: - Init

    init(targetSelectionPageModel: TargetSelectionPageModel,
         presenter: TargetSelectionPagePresentable,
         accountProvider: SourceAndTargetAccountProviding,
         listener: TargetSelectionListenerBridge,
         action: AssetAction,
         messageRecorder: MessageRecording = resolve()) {
        self.action = action
        self.targetSelectionPageModel = targetSelectionPageModel
        self.accountProvider = accountProvider
        self.messageRecorder = messageRecorder
        cryptoAddressViewModel = CryptoAddressTextFieldViewModel(
            validator: CryptoAddressValidator(model: targetSelectionPageModel),
            messageRecorder: messageRecorder
        )
        switch listener {
        case .simple(let didSelect):
            self.didSelect = didSelect
            self.listener = nil
        case .listener(let listener):
            self.didSelect = nil
            self.listener = listener
        }
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        cryptoAddressViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.targetSelectionPageModel.process(action: .qrScannerButtonTapped)
            }
            .disposeOnDeactivate(interactor: self)
        
        /// Listens to the `step` which
        /// triggers routing to a new screen or ending the flow
        targetSelectionPageModel
            .state
            .distinctUntilChanged(\.step)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] state in
                self?.handleStateChange(newState: state)
            }
            .disposeOnDeactivate(interactor: self)
        
        /// Fetch the source account provided.
        let sourceAccount = accountProvider.sourceAccount
            .map { account -> CryptoAccount in
                guard let crypto = account else {
                    fatalError("Expected a source account")
                }
                return crypto
            }
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        sourceAccount
            .map { (account) -> NSAttributedString in
                NSAttributedString(
                    string: String(format: LocalizationConstants.TextField.Title.cryptoAddress, account.currencyType.name),
                    attributes: [
                        .foregroundColor: UIColor.textFieldPlaceholder,
                        .font: UIFont.main(.medium, 16)
                    ]
                )
            }
            .bind(to: cryptoAddressViewModel.placeholderRelay)
            .disposeOnDeactivate(interactor: self)

        sourceAccount
            .subscribe(onNext: { [weak self] account in
                guard let self = self else { return }
                self.targetSelectionPageModel.process(action: .sourceAccountSelected(account, self.action))
            })
            .disposeOnDeactivate(interactor: self)
        
        let addressInput = cryptoAddressViewModel
            .text
            .skip(1)

        // bind for text updates
        addressInput
            .withLatestFrom(sourceAccount) { ($0, $1) }
            .subscribe(onNext: { [weak self] (address, account) in
                self?.targetSelectionPageModel.process(action: .validateAddress(address, account))
            })
            .disposeOnDeactivate(interactor: self)
        
        /// If the user has selected a wallet but then decides
        /// to enter in an address instead, the wallet selection state
        /// should be removed as soon as the user enters a character into the text field.
        addressInput
            .withLatestFrom(targetSelectionPageModel.state) { ($0, $1) }
            .filter { $0.1.inputValidated == .invalid }
            .filter { $0.1.destination != nil }
            .subscribe(onNext: { [weak self] (input, state) in
                self?.targetSelectionPageModel.process(action: .destinationDeselected)
            })
            .disposeOnDeactivate(interactor: self)

        let interactorState = targetSelectionPageModel
            .state
            .observeOn(MainScheduler.instance)
            .scan(.empty) { [weak self] (state, updater) -> TargetSelectionPageInteractor.State in
                guard let self = self else {
                    return state
                }
                return self.calculateNextState(with: state, updater: updater)
            }
            .asDriverCatchError()

        presenter.connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func calculateNextState(
        with state: State,
        updater: TargetSelectionPageState
    ) -> State {
        guard let sourceAccount = updater.sourceAccount as? SingleAccount else {
            fatalError("You should have a source account.")
        }
        let targets = updater.availableTargets
            .compactMap { $0 as? SingleAccount }

        let interactors = TargetSelectionPageInteractor.State.Interactors(
            sourceAccount: sourceAccount,
            availableTargets: targets,
            target: updater.destination as? SingleAccount,
            cryptoAddressViewModel: cryptoAddressViewModel
        )

        return state
            /// Update the `Interactors` for the cells.
            .update(keyPath: \.interactors, value: interactors)
            /// Update the enabled state of the `Next` button.
            .update(keyPath: \.actionButtonEnabled, value: updater.nextEnabled)
    }

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
            cryptoAddressViewModel.textRelay.accept("")
            targetSelectionPageModel.process(action: .destinationSelected(account))
        case .back,
             .closed:
            targetSelectionPageModel.process(action: .resetFlow)
        case .next:
            targetSelectionPageModel.process(action: .destinationConfirmed)
        case .none:
            break
        }
    }
    
    private var initialStep: Bool = true
    private func handleStateChange(newState: TargetSelectionPageState) {
        if !initialStep, newState.step == TargetSelectionPageStep.initial {
            finishFlow()
        } else {
            initialStep = false
            showFlowStep(newState: newState)
        }
    }

    private func finishFlow() {
        targetSelectionPageModel.process(action: .resetFlow)
    }
    
    private func showFlowStep(newState: TargetSelectionPageState) {
        guard !newState.isGoingBack else {
            listener?.didTapBack()
            return
        }
        switch newState.step {
        case .initial:
            break
        case .closed:
            targetSelectionPageModel.destroy()
            listener?.didTapClose()
        case .complete:
            guard let account = newState.destination else {
                fatalError("Expected a destination acount.")
            }
            didSelect?(account as! BlockchainAccount)
            listener?.didSelect(target: account)
        case .qrScanner:
            // TODO: Present QR Scanner
            break
        }
    }
    
    private func initialState() -> TargetSelectionPageState {
        TargetSelectionPageState(nextEnabled: false, destination: nil)
    }
}

extension TargetSelectionPageInteractor {
    struct State: StateType {
        static let empty = State(actionButtonEnabled: false)
        
        /// A model holding interactors for all `CellItems` on the Target Selection screen.
        /// `sourceInteractor` is the `From` account.
        /// `destinationInteractors` is all possible targets including the selected target.
        struct Interactors {
            static let empty = Interactors(sourceInteractor: nil, destinationInteractors: [], cryptoAddressViewModel: nil)
            let sourceInteractor: TargetSelectionPageCellItem.Interactor?
            let cryptoAddressViewModel: TextFieldViewModel?
            let destinationInteractors: [TargetSelectionPageCellItem.Interactor]

            private init(sourceInteractor: TargetSelectionPageCellItem.Interactor?,
                         destinationInteractors: [TargetSelectionPageCellItem.Interactor],
                         cryptoAddressViewModel: TextFieldViewModel?) {
                self.sourceInteractor = sourceInteractor
                self.destinationInteractors = destinationInteractors
                self.cryptoAddressViewModel = cryptoAddressViewModel
            }
            
            init(sourceAccount: SingleAccount,
                 availableTargets: [SingleAccount],
                 target: SingleAccount?,
                 cryptoAddressViewModel: TextFieldViewModel) {
                sourceInteractor = .singleAccount(sourceAccount, AccountAssetBalanceViewInteractor(account: sourceAccount))
                var destinations: [TargetSelectionPageCellItem.Interactor] = availableTargets.map { .singleAccountAvailableTarget($0) }
                if sourceAccount is NonCustodialAccount {
                    destinations.insert(.walletInputField(sourceAccount, cryptoAddressViewModel), at: 0)
                    self.cryptoAddressViewModel = cryptoAddressViewModel
                } else {
                    self.cryptoAddressViewModel = nil
                }
                /// If there is a target selected, filter it out from `destinations`
                /// and append it as a `singleAccountSelection`. This will show the
                /// radio cell as selected.
                if let account = target {
                    destinations = destinations.filter { $0.account.id != account.id }
                    destinations.append(.singleAccountSelection(account))
                }
                /// Order the destinations alphabetically.
                destinationInteractors = destinations.sorted { $0.account.label < $1.account.label }
            }
        }
        
        var interactors: Interactors
        var actionButtonEnabled: Bool
        
        private init(interactors: Interactors = .empty, actionButtonEnabled: Bool) {
            self.interactors = interactors
            self.actionButtonEnabled = actionButtonEnabled
        }
    }

    enum Effects {
        case select(BlockchainAccount)
        case next
        case back
        case closed
        case none
    }
}
