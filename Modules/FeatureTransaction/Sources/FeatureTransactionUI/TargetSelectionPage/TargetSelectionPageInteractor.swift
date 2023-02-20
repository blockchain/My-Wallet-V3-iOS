// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol TargetSelectionPageRouting: ViewableRouting {
    func presentQRScanner(
        sourceAccount: CryptoAccount,
        model: TargetSelectionPageModel
    )
}

protocol TargetSelectionPageListener: AnyObject {
    func didSelect(target: TransactionTarget)
    func didTapBack()
    func didTapClose()
}

final class TargetSelectionPageInteractor: PresentableInteractor<TargetSelectionPagePresentable>,
    TargetSelectionPageInteractable
{

    weak var router: TargetSelectionPageRouting?

    // MARK: - Private Properties

    private let accountProvider: SourceAndTargetAccountProviding
    private let targetSelectionPageModel: TargetSelectionPageModel
    private let action: AssetAction
    private let messageRecorder: MessageRecording
    private let didSelect: AccountPickerDidSelect?
    private let backButtonInterceptor: BackButtonInterceptor
    private let radioSelectionHandler: RadioSelectionHandling
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    weak var listener: TargetSelectionPageListener?

    // MARK: - Init

    init(
        targetSelectionPageModel: TargetSelectionPageModel,
        presenter: TargetSelectionPagePresentable,
        accountProvider: SourceAndTargetAccountProviding,
        listener: TargetSelectionListenerBridge,
        action: AssetAction,
        radioSelectionHandler: RadioSelectionHandling,
        backButtonInterceptor: @escaping BackButtonInterceptor,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        messageRecorder: MessageRecording = resolve()
    ) {
        self.action = action
        self.targetSelectionPageModel = targetSelectionPageModel
        self.accountProvider = accountProvider
        self.messageRecorder = messageRecorder
        self.backButtonInterceptor = backButtonInterceptor
        self.radioSelectionHandler = radioSelectionHandler
        self.enabledCurrenciesService = enabledCurrenciesService
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

        let cryptoAddressViewModel = CryptoAddressTextFieldViewModel(
            validator: CryptoAddressValidator(model: targetSelectionPageModel),
            messageRecorder: messageRecorder
        )

        let transactionState = targetSelectionPageModel.state
            .share(replay: 1, scope: .whileConnected)

        // This returns an observable from the TransactionModel and its state.
        // Since the TargetSelection has it's own model/state/actions we need to intercept when the back button
        // of the TransactionFlow occurs and update the TargetSelection state
        backButtonInterceptor()
            .subscribe(onNext: { [weak self] state in
                let hasCorrectBackStack = state.backStack.isEmpty || state.backStack.contains(.selectTarget)
                let hasCorrectStep = state.step == .enterAmount || state.step == .selectTarget
                if hasCorrectStep, hasCorrectBackStack, state.isGoingBack {
                    self?.targetSelectionPageModel.process(action: .returnToPreviousStep)
                }
            })
            .disposeOnDeactivate(interactor: self)

        /// Fetch the source account provided.
        let sourceAccount = accountProvider.sourceAccount
            .map { account -> BlockchainAccount in
                guard let crypto = account else {
                    fatalError("Expected a source account")
                }
                return crypto
            }
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        /// Any text coming from the `State` we want to bind
        /// to the `cryptoAddressViewModel` textRelay.
        transactionState
            .map(\.inputValidated)
            .map(\.text)
            .bind(to: cryptoAddressViewModel.originalTextRelay)
            .disposeOnDeactivate(interactor: self)

        let requiredValidationAction = transactionState
            .map(\.inputValidated)
            /// Only the QR scanner requires validation. The textfield
            /// validates itself so long as it's in focus.
            .filter(\.requiresValidation)
            /// We get the text from the `State` and not the textField.
            /// This is **only** for the QR scanner. This is to prevent
            /// conflating text entry with QR scanning or deep linking.
            .map(\.text)
            .distinctUntilChanged()

        requiredValidationAction
            .withLatestFrom(sourceAccount) { ($0, $1) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text, account in
                self?.targetSelectionPageModel.process(action: .validateAddress(text, account))
            })
            .disposeOnDeactivate(interactor: self)

        /// The text the user has entered into the textField
        let text = cryptoAddressViewModel
            .text
            .distinctUntilChanged()

        /// Whether or not the textField is in focus
        let isFocused = cryptoAddressViewModel
            .focusRelay
            /// We only want to update the `State` with a text entry value
            /// when the text field is not in focus.
            .map { $0 == .on }

        // `textWhileTyping` stream the text field text while it has focus.
        let textWhileTyping: Observable<String> = text
            .withLatestFrom(isFocused) { ($0, $1) }
            .filter(\.1)
            .map(\.0)
            .share(replay: 1, scope: .whileConnected)

        // As soon as something is inputted, we want to disable the 'next' action.
        textWhileTyping
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.targetSelectionPageModel.process(action: .destinationDeselected)
            })
            .disposeOnDeactivate(interactor: self)

        // The stream is debounced and we then process the validation.
        textWhileTyping
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .withLatestFrom(sourceAccount) { ($0, $1) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text, account in
                self?.targetSelectionPageModel.process(action: .validateAddress(text, account))
            })
            .disposeOnDeactivate(interactor: self)

        /// Launch the QR scanner should the button be tapped
        cryptoAddressViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.targetSelectionPageModel.process(action: .qrScannerButtonTapped)
            }
            .disposeOnDeactivate(interactor: self)

        /// Binding for radio selection state
        let initialTargetsAction = transactionState
            .map(\.availableTargets)
            .map { $0.compactMap { $0 as? SingleAccount }.map(\.identifier) }
            .distinctUntilChanged()
            .map(RadioSelectionAction.initialValues)

        let deselectAction = Observable.merge(textWhileTyping, requiredValidationAction)
            .map { _ in RadioSelectionAction.deselectAll }

        let radioSelectionAction = transactionState
            // a selected input is inferred if the inputValidated is TargetSelectionInputValidation.account
            .filter(\.inputValidated.isAccountSelection)
            .compactMap { $0.destination as? SingleAccount }
            .map(\.identifier)
            .map(RadioSelectionAction.select)

        Observable.merge(
            initialTargetsAction,
            deselectAction,
            radioSelectionAction
        )
        .bind(to: radioSelectionHandler.selectionAction)
        .disposeOnDeactivate(interactor: self)

        /// Listens to the `step` which
        /// triggers routing to a new screen or ending the flow
        transactionState
            .distinctUntilChanged(\.step)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] newState in
                self?.handleStateChange(newState: newState)
            })
            .disposeOnDeactivate(interactor: self)

        sourceAccount
            .map(\.currencyType)
            .map { [enabledCurrenciesService] currency -> String in
                Self.addressFieldWarning(enabledCurrenciesService: enabledCurrenciesService, currency: currency)
            }
            .bind(to: cryptoAddressViewModel.subtitleRelay)
            .disposeOnDeactivate(interactor: self)

        sourceAccount
            .subscribe(onNext: { [weak self] account in
                guard let self else { return }
                self.targetSelectionPageModel.process(action: .sourceAccountSelected(account, self.action))
            })
            .disposeOnDeactivate(interactor: self)

        let interactorState = transactionState
            .observe(on: MainScheduler.instance)
            .scan(.empty) { [weak self] state, updater -> TargetSelectionPageInteractor.State in
                guard let self else {
                    return state
                }
                guard updater.sourceAccount != nil else {
                    /// We cannot proceed to the calculation step without a `sourceAccount`
                    Logger.shared.debug("No sourceAccount: \(updater)")
                    return state
                }
                return self.calculateNextState(
                    with: state,
                    updater: updater,
                    cryptoAddressViewModel: cryptoAddressViewModel
                )
            }
            .asDriverCatchError()

        presenter.connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func calculateNextState(
        with state: State,
        updater: TargetSelectionPageState,
        cryptoAddressViewModel: CryptoAddressTextFieldViewModel
    ) -> State {
        guard let sourceAccount = updater.sourceAccount as? SingleAccount else {
            fatalError("You should have a source account.")
        }
        var state = state

        if state.sourceInteractor?.account.identifier != sourceAccount.identifier {
            state = state
                .update(
                    keyPath: \.sourceInteractor,
                    value: .singleAccount(sourceAccount, AccountAssetBalanceViewInteractor(account: sourceAccount))
                )
        }

        if state.destinationInteractors.isEmpty {
            let targets = updater.availableTargets.compactMap { $0 as? SingleAccount }
            let destinations: [TargetSelectionPageCellItem.Interactor] = targets.map { account in
                .singleAccountAvailableTarget(
                    RadioAccountCellInteractor(account: account, radioSelectionHandler: self.radioSelectionHandler)
                )
            }
            .sorted { $0.account.label < $1.account.label }
            state = state
                .update(keyPath: \.destinationInteractors, value: destinations)
        }

        if state.inputFieldInteractor == nil {
            state = state
                .update(
                    keyPath: \.inputFieldInteractor,
                    value: .walletInputField(sourceAccount, cryptoAddressViewModel)
                )
        }

        return state
            /// Update the enabled state of the `Next` button.
            .update(keyPath: \.actionButtonEnabled, value: updater.nextEnabled)
    }

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
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
            // no-op
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
            didSelect?(account as! SingleAccount)
            listener?.didSelect(target: account)
        case .qrScanner:
            guard let sourceAccount = newState.sourceAccount else {
                fatalError("Expected a sourceAccount: \(newState)")
            }
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected a CryptoAccount: \(sourceAccount)")
            }
            router?.presentQRScanner(
                sourceAccount: cryptoAccount,
                model: targetSelectionPageModel
            )
        }
    }

    private func initialState() -> TargetSelectionPageState {
        TargetSelectionPageState(nextEnabled: false, destination: nil)
    }

    private static func addressFieldWarning(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        currency: CurrencyType
    ) -> String {
        func defaultWarning() -> String {
            LocalizationConstants.TextField.Title.sendToCryptoWallet(
                displayCode: currency.displaySymbol,
                networkName: currency.name
            )
        }
        return addressFieldERC20Warning(
            enabledCurrenciesService: enabledCurrenciesService,
            currency: currency
        )
        ?? defaultWarning()
    }

    private static func addressFieldERC20Warning(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        currency: CurrencyType
    ) -> String? {

        guard let erc20ParentChain: String = currency
            .cryptoCurrency?
            .assetModel
            .kind
            .erc20ParentChain
        else {
            return nil
        }
        let networkName: String? = enabledCurrenciesService.allEnabledEVMNetworks
            .first(where: { $0.networkConfig.networkTicker == erc20ParentChain })?
            .networkConfig
            .name

        return LocalizationConstants.TextField.Title.sendToCryptoWallet(
            displayCode: currency.displaySymbol,
            networkName: networkName ?? erc20ParentChain
        )
    }
}

extension TargetSelectionPageInteractor {
    struct State: StateType {
        static let empty = State(actionButtonEnabled: false)
        var sourceInteractor: TargetSelectionPageCellItem.Interactor?
        var inputFieldInteractor: TargetSelectionPageCellItem.Interactor?
        var destinationInteractors: [TargetSelectionPageCellItem.Interactor]

        var actionButtonEnabled: Bool

        private init(actionButtonEnabled: Bool) {
            self.actionButtonEnabled = actionButtonEnabled
            self.sourceInteractor = nil
            self.inputFieldInteractor = nil
            self.destinationInteractors = []
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
