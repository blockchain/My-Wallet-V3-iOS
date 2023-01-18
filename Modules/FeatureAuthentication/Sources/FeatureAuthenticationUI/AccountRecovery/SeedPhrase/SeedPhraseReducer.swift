// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit
import WalletPayloadKit

// MARK: - Type

public enum WalletRecoveryIds {
    public struct RecoveryId: Hashable {}
    public struct ImportId: Hashable {}
    public struct AccountRecoveryAfterResetId: Hashable {}
    public struct WalletFetchAfterRecoveryId: Hashable {}
}

public enum SeedPhraseAction: Equatable {

    public enum URLContent {

        case contactSupport

        var url: URL? {
            switch self {
            case .contactSupport:
                return URL(string: Constants.SupportURL.ResetAccount.contactSupport)
            }
        }
    }

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case alert(AlertAction)
    case didChangeSeedPhrase(String)
    case didChangeSeedPhraseScore(MnemonicValidationScore)
    case validateSeedPhrase
    case setResetPasswordScreenVisible(Bool)
    case setResetAccountBottomSheetVisible(Bool)
    case setLostFundsWarningScreenVisible(Bool)
    case setImportWalletScreenVisible(Bool)
    case setSecondPasswordNoticeVisible(Bool)
    case resetPassword(ResetPasswordAction)
    case resetAccountWarning(ResetAccountWarningAction)
    case lostFundsWarning(LostFundsWarningAction)
    case importWallet(ImportWalletAction)
    case secondPasswordNotice(SecondPasswordNotice.Action)
    case restoreWallet(WalletRecovery)
    case restored(Result<Either<EmptyValue, WalletFetchedContext>, WalletRecoveryError>)
    case imported(Result<EmptyValue, WalletRecoveryError>)
    case accountCreation(Result<WalletCreatedContext, WalletCreationServiceError>)
    case accountRecovered(AccountResetContext)
    case walletFetched(Result<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>)
    case informWalletFetched(WalletFetchedContext)
    case triggerAuthenticate // needed for legacy wallet flow
    case open(urlContent: URLContent)
    case none
}

public enum AccountRecoveryContext: Equatable {
    case troubleLoggingIn
    case restoreWallet
    case none
}

public struct AccountResetContext: Equatable {
    let walletContext: WalletCreatedContext
    let offlineToken: NabuOfflineToken
}

// MARK: - Properties

public struct SeedPhraseState: Equatable {
    var context: AccountRecoveryContext
    var emailAddress: String
    var nabuInfo: WalletInfo.Nabu?
    var seedPhrase: String
    var seedPhraseScore: MnemonicValidationScore
    var isResetPasswordScreenVisible: Bool
    var isResetAccountBottomSheetVisible: Bool
    var isLostFundsWarningScreenVisible: Bool
    var isImportWalletScreenVisible: Bool
    var isSecondPasswordNoticeVisible: Bool
    var resetPasswordState: ResetPasswordState?
    var resetAccountWarningState: ResetAccountWarningState?
    var lostFundsWarningState: LostFundsWarningState?
    var importWalletState: ImportWalletState?
    var secondPasswordNoticeState: SecondPasswordNotice.State?
    var failureAlert: AlertState<SeedPhraseAction>?
    var isLoading: Bool

    var accountResettable: Bool {
        guard let nabuInfo else {
            return false
        }
        return nabuInfo.recoverable
    }

    init(context: AccountRecoveryContext, emailAddress: String = "", nabuInfo: WalletInfo.Nabu? = nil) {
        self.context = context
        self.emailAddress = emailAddress
        self.nabuInfo = nabuInfo
        self.seedPhrase = ""
        self.seedPhraseScore = .none
        self.isResetPasswordScreenVisible = false
        self.isResetAccountBottomSheetVisible = false
        self.isLostFundsWarningScreenVisible = false
        self.isImportWalletScreenVisible = false
        self.isSecondPasswordNoticeVisible = false
        self.failureAlert = nil
        self.isLoading = false
    }
}

struct SeedPhraseEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validator: SeedPhraseValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let passwordValidator: PasswordValidatorAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI
    let signUpCountriesService: SignUpCountriesServiceAPI
    let errorRecorder: ErrorRecording
    let featureFlagsService: FeatureFlagsServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        validator: SeedPhraseValidatorAPI = resolve(),
        passwordValidator: PasswordValidatorAPI = resolve(),
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI,
        signUpCountriesService: SignUpCountriesServiceAPI = resolve(),
        errorRecorder: ErrorRecording,
        recaptchaService: GoogleRecaptchaServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.validator = validator
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
        self.signUpCountriesService = signUpCountriesService
        self.errorRecorder = errorRecorder
        self.recaptchaService = recaptchaService
        self.featureFlagsService = featureFlagsService
    }
}

let seedPhraseReducer = Reducer.combine(
    secondPasswordNoticeReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.secondPasswordNoticeState,
            action: /SeedPhraseAction.secondPasswordNotice,
            environment: {
                SecondPasswordNotice.Environment(
                    externalAppOpener: $0.externalAppOpener
                )
            }
        ),
    importWalletReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.importWalletState,
            action: /SeedPhraseAction.importWallet,
            environment: {
                ImportWalletEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    signUpCountriesService: $0.signUpCountriesService,
                    featureFlagsService: $0.featureFlagsService,
                    recaptchaService: $0.recaptchaService
                )
            }
        ),
    resetAccountWarningReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetAccountWarningState,
            action: /SeedPhraseAction.resetAccountWarning,
            environment: {
                ResetAccountWarningEnvironment(
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    lostFundsWarningReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.lostFundsWarningState,
            action: /SeedPhraseAction.lostFundsWarning,
            environment: {
                LostFundsWarningEnvironment(
                    mainQueue: $0.mainQueue,
                    analyticsRecorder: $0.analyticsRecorder,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    resetPasswordReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetPasswordState,
            action: /SeedPhraseAction.resetPassword,
            environment: {
                ResetPasswordEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    // swiftlint:disable closure_body_length
    Reducer<
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseEnvironment
    > { state, action, environment in
        switch action {

        case .didChangeSeedPhrase(let seedPhrase):
            state.seedPhrase = seedPhrase
            return Effect(value: .validateSeedPhrase)

        case .didChangeSeedPhraseScore(let score):
            state.seedPhraseScore = score
            return .none

        case .validateSeedPhrase:
            return environment
                .validator
                .validate(phrase: state.seedPhrase)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> SeedPhraseAction in
                    guard case .success(let score) = result else {
                        return .none
                    }
                    return .didChangeSeedPhraseScore(score)
                }

        case .setResetPasswordScreenVisible(let isVisible):
            state.isResetPasswordScreenVisible = isVisible
            if isVisible {
                state.resetPasswordState = .init()
            }
            return .none

        case .setResetAccountBottomSheetVisible(let isVisible):
            state.isResetAccountBottomSheetVisible = isVisible
            if isVisible {
                state.resetAccountWarningState = .init()
            }
            return .none

        case .setLostFundsWarningScreenVisible(let isVisible):
            state.isLostFundsWarningScreenVisible = isVisible
            if isVisible {
                state.lostFundsWarningState = .init()
            }
            return .none

        case .setImportWalletScreenVisible(let isVisible):
            state.isImportWalletScreenVisible = isVisible
            if isVisible {
                state.importWalletState = .init(mnemonic: state.seedPhrase)
            }
            return .none

        case .setSecondPasswordNoticeVisible(let isVisible):
            state.isSecondPasswordNoticeVisible = isVisible
            if isVisible {
                state.secondPasswordNoticeState = .init()
            }
            return .none

        case .resetPassword:
            // handled in reset password reducer
            return .none

        case .resetAccountWarning(.retryButtonTapped),
             .resetAccountWarning(.onDisappear):
            return Effect(value: .setResetAccountBottomSheetVisible(false))

        case .resetAccountWarning(.continueResetButtonTapped):
            return .concatenate(
                Effect(value: .setResetAccountBottomSheetVisible(false)),
                Effect(value: .setLostFundsWarningScreenVisible(true))
            )

        case .lostFundsWarning(.goBackButtonTapped):
            return Effect(value: .setLostFundsWarningScreenVisible(false))

        case .lostFundsWarning(.resetPassword(.reset(let password))):
            guard let nabuInfo = state.nabuInfo else {
                return .none
            }
            let accountName = NonLocalizedConstants.defiWalletTitle
            return .concatenate(
                Effect(value: .triggerAuthenticate),
                environment.walletCreationService
                    .createWallet(
                        state.emailAddress,
                        password,
                        accountName,
                        nil
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: CreateAccountStepTwoIds.CreationId(), cancelInFlight: true)
                    .map(SeedPhraseAction.accountCreation)
            )

        case .accountCreation(.failure(let error)):
            let title = LocalizationConstants.Errors.error
            let message = error.localizedDescription
            state.lostFundsWarningState?.resetPasswordState?.isLoading = false
            return .merge(
                Effect(
                    value: .alert(
                        .show(
                            title: title,
                            message: message
                        )
                    )
                ),
                .cancel(id: CreateAccountStepTwoIds.CreationId())
            )

        case .accountCreation(.success(let context)):
            guard let nabuInfo = state.nabuInfo else {
                return .none
            }
            return .merge(
                .cancel(id: CreateAccountStepTwoIds.CreationId()),
                environment.accountRecoveryService
                    .recoverUser(
                        guid: context.guid,
                        sharedKey: context.sharedKey,
                        userId: nabuInfo.userId,
                        recoveryToken: nabuInfo.recoveryToken
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: WalletRecoveryIds.AccountRecoveryAfterResetId(), cancelInFlight: false)
                    .map { result -> SeedPhraseAction in
                        guard case .success(let offlineToken) = result else {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvents.New.AccountRecoveryFlow.accountRecoveryFailed
                            )
                            // show recovery failures if the endpoint fails
                            return .lostFundsWarning(
                                .resetPassword(
                                    .setResetAccountFailureVisible(true)
                                )
                            )
                        }
                        environment.analyticsRecorder.record(
                            event: AnalyticsEvents.New.AccountRecoveryFlow
                                .accountPasswordReset(hasRecoveryPhrase: false)
                        )
                        return .accountRecovered(
                            AccountResetContext(
                                walletContext: context,
                                offlineToken: offlineToken
                            )
                        )
                    }
            )

        case .accountRecovered(let info):
            // NOTE: The effects of fetching a wallet still happen on the CoreCoordinator
            // Unfortunately Resetting an account and wallet fetching are related
            // In order to save the token wallet metadata we need
            // to have a fully loaded wallet so the following happens:
            // 1) Fetch the wallet
            // 2) Store the offlineToken to the wallet metadata
            // There's no error handling as any error will be overruled by the CoreCoordinator
            return .merge(
                .cancel(id: WalletRecoveryIds.AccountRecoveryAfterResetId()),
                environment.walletFetcherService
                    .fetchWalletAfterAccountRecovery(
                        info.walletContext.guid,
                        info.walletContext.sharedKey,
                        info.walletContext.password,
                        info.offlineToken
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: WalletRecoveryIds.WalletFetchAfterRecoveryId())
                    .map(SeedPhraseAction.walletFetched)
            )

        case .walletFetched(.success(.left(.noValue))):
            // this is for legacy JS flow, to be removed
            return .none

        case .walletFetched(.success(.right(let context))):
            return Effect(value: .informWalletFetched(context))

        case .walletFetched(.failure(let error)):
            let title = LocalizationConstants.ErrorAlert.title
            let message = error.errorDescription ?? LocalizationConstants.ErrorAlert.message
            return Effect(
                value: .alert(
                    .show(title: title, message: message)
                )
            )

        case .informWalletFetched:
            // handled in WelcomeReducer
            return .none

        case .lostFundsWarning:
            return .none

        case .importWallet(.goBackButtonTapped):
            return Effect(value: .setImportWalletScreenVisible(false))

        case .importWallet(.createAccount(.triggerAuthenticate)):
            return Effect(value: .triggerAuthenticate)

        case .importWallet:
            return .none

        case .secondPasswordNotice:
            return .none

        case .restoreWallet(.metadataRecovery(let mnemonic)):
            state.isLoading = true
            return .concatenate(
                Effect(value: .triggerAuthenticate),
                environment.walletRecoveryService
                    .recoverFromMetadata(mnemonic)
                    .receive(on: environment.mainQueue)
                    .mapError(WalletRecoveryError.restoreFailure)
                    .catchToEffect()
                    .cancellable(id: WalletRecoveryIds.RecoveryId(), cancelInFlight: true)
                    .map(SeedPhraseAction.restored)
            )
        case .restoreWallet:
            return .none

        case .restored(.success(.left(.noValue))):
            state.isLoading = false
            return .cancel(id: WalletRecoveryIds.RecoveryId())

        case .restored(.success(.right(let context))):
            state.isLoading = false
            return .merge(
                .cancel(id: WalletRecoveryIds.RecoveryId()),
                Effect(value: .informWalletFetched(context))
            )

        case .restored(.failure(.restoreFailure(.recovery(.unableToRecoverFromMetadata)))):
            state.isLoading = false
            return .merge(
                .cancel(id: WalletRecoveryIds.RecoveryId()),
                Effect(value: .setImportWalletScreenVisible(true))
            )

        case .restored(.failure(.restoreFailure(let error))):
            state.isLoading = false
            let title = LocalizationConstants.Errors.error
            let message = error.errorDescription ?? LocalizationConstants.Errors.genericError
            return .merge(
                .cancel(id: WalletRecoveryIds.RecoveryId()),
                Effect(value: .alert(.show(title: title, message: message)))
            )

        case .imported(.success):
            return .cancel(id: WalletRecoveryIds.ImportId())

        case .imported(.failure(let error)):
            guard state.importWalletState != nil else {
                return .none
            }
            return Effect(value: .importWallet(.importWalletFailed(error)))

        case .open(let urlContent):
            guard let url = urlContent.url else {
                return .none
            }
            environment.externalAppOpener.open(url)
            return .none

        case .triggerAuthenticate:
            return .none

        case .alert(.show(let title, let message)):
            state.failureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.alert(.dismiss))
                )
            )
            return .none

        case .alert(.dismiss):
            state.failureAlert = nil
            return .none

        case .none:
            return .none
        }
    }
)
.analytics()

// MARK: - Extension

extension Reducer where
    Action == SeedPhraseAction,
    State == SeedPhraseState,
    Environment == SeedPhraseEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                SeedPhraseState,
                SeedPhraseAction,
                SeedPhraseEnvironment
            > { _, action, environment in
                switch action {
                case .setResetPasswordScreenVisible(true):
                    environment.analyticsRecorder.record(
                        event: .recoveryPhraseEntered
                    )
                    return .none
                case .setImportWalletScreenVisible(true):
                    environment.analyticsRecorder.record(
                        event: .recoveryPhraseEntered
                    )
                    return .none
                case .setResetAccountBottomSheetVisible(true):
                    environment.analyticsRecorder.record(
                        event: .resetAccountClicked
                    )
                    return .none
                case .setResetAccountBottomSheetVisible(false):
                    environment.analyticsRecorder.record(
                        event: .resetAccountCancelled
                    )
                    return .none
                case .setLostFundsWarningScreenVisible(true):
                    environment.analyticsRecorder.record(
                        event: .resetAccountCancelled
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
