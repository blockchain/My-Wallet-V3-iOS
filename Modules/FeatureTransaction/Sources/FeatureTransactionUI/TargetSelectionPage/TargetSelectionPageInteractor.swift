// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
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
    private let messageRecorder: MessageRecording
    private let backButtonInterceptor: BackButtonInterceptor
    private let radioSelectionHandler: RadioSelectionHandling
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    weak var listener: TargetSelectionPageListener?

    // MARK: - Init

    init(
        targetSelectionPageModel: TargetSelectionPageModel,
        presenter: TargetSelectionPagePresentable,
        accountProvider: SourceAndTargetAccountProviding,
        listener: TargetSelectionPageListener,
        radioSelectionHandler: RadioSelectionHandling,
        backButtonInterceptor: @escaping BackButtonInterceptor,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        messageRecorder: MessageRecording = resolve()
    ) {
        self.targetSelectionPageModel = targetSelectionPageModel
        self.accountProvider = accountProvider
        self.messageRecorder = messageRecorder
        self.backButtonInterceptor = backButtonInterceptor
        self.radioSelectionHandler = radioSelectionHandler
        self.enabledCurrenciesService = enabledCurrenciesService
        self.listener = listener
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let inputFieldViewModel = CryptoAddressTextFieldViewModel.create(
            validator: CryptoAddressValidator(model: targetSelectionPageModel),
            messageRecorder: messageRecorder
        )

        let memoFieldViewModel = MemoTextFieldViewModel.create(
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
                guard let account else {
                    fatalError("Expected a source account")
                }
                return account
            }
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        /// Any text coming from the `State` we want to bind
        /// to the `inputFieldViewModel` textRelay.
        transactionState
            .map(\.inputValidated.text)
            .bind(to: inputFieldViewModel.originalTextRelay)
            .disposeOnDeactivate(interactor: self)

        /// Any memo coming from the `State` we want to bind
        /// to the `memoFieldViewModel` textRelay.
        transactionState
            .map(\.inputValidated.memoText)
            .bind(to: memoFieldViewModel.originalTextRelay)
            .disposeOnDeactivate(interactor: self)

        // MARK: Memo Text

        // The text the user has entered into the textField
        let memoText = memoFieldViewModel
            .text
            .distinctUntilChanged()

        // Whether or not the inputFieldViewModel is in focus
        let memoIsFocused = memoFieldViewModel
            .focusRelay
            .map(\.isOn)

        // `memoTextWhileTyping` stream the text field text while it has focus.
        let memoTextWhileTyping: Observable<String> = memoText
            .withLatestFrom(memoIsFocused) { ($0, $1) }
            .filter(\.1)
            .map(\.0)
            .share(replay: 1, scope: .whileConnected)

        // MARK: Input Text

        // The text the user has entered into the textField
        let inputText = inputFieldViewModel
            .text
            .distinctUntilChanged()

        // Whether or not the inputFieldViewModel is in focus
        let inputIsFocused = inputFieldViewModel
            .focusRelay
            .map(\.isOn)

        // `textWhileTyping` stream the text field text while it has focus.
        let inputTextWhileTyping: Observable<String> = inputText
            .withLatestFrom(inputIsFocused) { ($0, $1) }
            .filter(\.1)
            .map(\.0)
            .share(replay: 1, scope: .whileConnected)

        // MARK: Memo And Text

        // As soon as something is inputted, we want to disable the 'next' action.
        Observable
            .merge(inputTextWhileTyping.mapToVoid(), memoTextWhileTyping.mapToVoid())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.targetSelectionPageModel.process(action: .destinationDeselected)
            })
            .disposeOnDeactivate(interactor: self)

        // The stream is debounced and we then process the validation.
        memoTextWhileTyping
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .withLatestFrom(Observable.combineLatest(inputText, sourceAccount)) { (memo, values) in
                (memo, values.0, values.1)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] memo, inputText, account in
                self?.targetSelectionPageModel.process(action: .validate(address: inputText, memo: memo, sourceAccount: account))
            })
            .disposeOnDeactivate(interactor: self)

        // The stream is debounced and we then process the validation.
        inputTextWhileTyping
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .withLatestFrom(Observable.combineLatest(memoText, sourceAccount)) { (text, values) in
                (text, values.0, values.1)
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text, memo, account in
                self?.targetSelectionPageModel.process(action: .validate(address: text, memo: memo, sourceAccount: account))
            })
            .disposeOnDeactivate(interactor: self)

        // Launch the QR scanner should the button be tapped
        inputFieldViewModel
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

        let deselectAction = Observable.merge(inputTextWhileTyping, memoTextWhileTyping)
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
            .bind(to: inputFieldViewModel.subtitleRelay)
            .disposeOnDeactivate(interactor: self)

        sourceAccount
            .subscribe(onNext: { [weak self] account in
                guard let self else { return }
                targetSelectionPageModel.process(action: .sourceAccountSelected(account, .send))
            })
            .disposeOnDeactivate(interactor: self)

        let interactorState = transactionState
            .observe(on: MainScheduler.instance)
            .scan(.empty) { [weak self] state, updater -> TargetSelectionPageInteractor.State in
                guard let self else {
                    return state
                }
                return calculateNextState(
                    with: state,
                    updater: updater,
                    inputFieldViewModel: inputFieldViewModel,
                    memoFieldViewModel: memoFieldViewModel
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
        inputFieldViewModel: TextFieldViewModel,
        memoFieldViewModel: TextFieldViewModel
    ) -> State {
        guard let sourceAccount = updater.sourceAccount else {
            /// We cannot proceed to the calculation step without a `sourceAccount`
            Logger.shared.debug("No sourceAccount: \(updater)")
            return state
        }
        guard let sourceAccount = sourceAccount as? SingleAccount else {
            fatalError("sourceAccount not a `SingleAccount`")
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
            let destinations: [TargetSelectionPageCellItem.Interactor] = targets.map { [radioSelectionHandler] account in
                .singleAccountAvailableTarget(
                    RadioAccountCellInteractor(account: account, radioSelectionHandler: radioSelectionHandler)
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
                    value: .walletInputField(sourceAccount, inputFieldViewModel)
                )
        }
        if state.memoFieldInteractor == nil, TransactionMemoSupport.supportsMemo(sourceAccount.currencyType) {
            state = state
                .update(
                    keyPath: \.memoFieldInteractor,
                    value: .memo(sourceAccount, memoFieldViewModel)
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
        if initialStep.isNo, newState.step == TargetSelectionPageStep.initial {
            // no-op
            return
        }
        initialStep = false
        guard newState.isGoingBack.isNo else {
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
        var defaultWarning: String {
            LocalizationConstants.TextField.Title.sendToCryptoWallet(
                displayCode: currency.displaySymbol,
                networkName: currency.name
            )
        }
        guard let cryptoCurrency = currency.cryptoCurrency else {
            return defaultWarning
        }
        guard let network = enabledCurrenciesService.network(for: cryptoCurrency) else {
            return defaultWarning
        }
        return LocalizationConstants.TextField.Title.sendToCryptoWallet(
            displayCode: currency.displaySymbol,
            networkName: network.networkConfig.shortName
        )
    }
}

extension TargetSelectionPageInteractor {
    struct State: StateType {
        static let empty = State(actionButtonEnabled: false)
        var sourceInteractor: TargetSelectionPageCellItem.Interactor?
        var inputFieldInteractor: TargetSelectionPageCellItem.Interactor?
        var memoFieldInteractor: TargetSelectionPageCellItem.Interactor?
        var destinationInteractors: [TargetSelectionPageCellItem.Interactor]

        var actionButtonEnabled: Bool

        private init(actionButtonEnabled: Bool) {
            self.actionButtonEnabled = actionButtonEnabled
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
