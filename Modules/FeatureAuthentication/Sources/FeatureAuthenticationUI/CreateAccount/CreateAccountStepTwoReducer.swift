// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import ErrorsUI
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit
import WalletPayloadKit

private typealias L10n = LocalizationConstants.FeatureAuthentication.CreateAccount

public enum CreateAccountStepTwoRoute: NavigationRoute {

    public func destination(in store: Store<CreateAccountStepTwoState, CreateAccountStepTwoAction>) -> some View {
        Text(String(describing: self))
    }
}

public enum CreateAccountStepTwoIds {
    public struct CreationId: Hashable {}
    public struct ImportId: Hashable {}
    public struct RecaptchaId: Hashable {}
}

public enum CreateAccountContextStepTwo: Equatable {
    case importWallet(mnemonic: String)
    case createWallet

    var mnemonic: String? {
        switch self {
        case .importWallet(let mnemonic):
            return mnemonic
        case .createWallet:
            return nil
        }
    }
}

public struct CreateAccountStepTwoState: Equatable, NavigationState {

    public enum InputValidationError: Equatable {
        case invalidEmail
        case weakPassword([PasswordValidationRule])
        case termsNotAccepted
        case passwordsDontMatch
    }

    public enum InputValidationState: Equatable {
        case unknown
        case valid
        case invalid(InputValidationError)

        var isInvalid: Bool {
            switch self {
            case .invalid:
                return true
            case .valid, .unknown:
                return false
            }
        }
    }

    public enum Field: Equatable {
        case email
        case password
    }

    enum AddressSegmentPicker: Hashable {
        case country
        case countryState
    }

    public var route: RouteIntent<CreateAccountStepTwoRoute>?

    public var context: CreateAccountContextStepTwo

    public var country: SearchableItem<String>
    public var countryState: SearchableItem<String>?
    public var referralCode: String
    // User Input
    @BindingState public var emailAddress: String
    @BindingState public var password: String
    @BindingState public var passwordConfirmation: String
    @BindingState public var termsAccepted: Bool = false
    @BindingState public var bakktTermsAccepted: Bool = false
    @BindingState public var fatalError: UX.Error?
    @BindingState public var shouldDisplayBakktTermsAndConditions: Bool = false
    // Form interaction
    @BindingState public var passwordFieldTextVisible: Bool = false

    // Validation
    public var validatingInput: Bool = false
    public var passwordRulesBreached: [PasswordValidationRule]
    public var inputValidationState: InputValidationState
    public var inputConfirmationValidationState: InputValidationState
    public var failureAlert: AlertState<CreateAccountStepTwoAction>?

    public var isCreatingWallet = false

    var isCreateButtonDisabled: Bool {
        validatingInput
        || inputValidationState.isInvalid
        || inputConfirmationValidationState.isInvalid
        || isCreatingWallet
        || fatalError != nil
        || !termsAccepted
        || !bakktTermsAccepted && shouldDisplayBakktTermsAndConditions
        || emailAddress.isEmpty
        || password.isEmpty
        || passwordConfirmation.isEmpty
    }

    public init(
        context: CreateAccountContextStepTwo,
        country: SearchableItem<String>,
        countryState: SearchableItem<String>?,
        referralCode: String
    ) {
        self.context = context
        self.country = country
        self.countryState = countryState
        self.referralCode = referralCode
        self.emailAddress = ""
        self.password = ""
        self.passwordConfirmation = ""
        self.passwordRulesBreached = []
        self.inputValidationState = .unknown
        self.inputConfirmationValidationState = .unknown
    }
}

public enum CreateAccountStepTwoAction: Equatable, NavigationAction, BindableAction {

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case onAppear
    case binding(BindingAction<CreateAccountStepTwoState>)
    // use `createAccount` to perform the account creation. this action is fired after the user confirms the details and the input is validated.
    case createOrImportWallet(CreateAccountContextStepTwo)
    case createAccount(Result<String, GoogleRecaptchaError>)
    case importAccount(_ mnemonic: String)
    case createButtonTapped
    case didValidateAfterFormSubmission
    case didUpdatePasswordRules([PasswordValidationRule])
    case didUpdateInputValidation(CreateAccountStepTwoState.InputValidationState)
    case openExternalLink(URL)
    case onWillDisappear
    case route(RouteIntent<CreateAccountStepTwoRoute>?)
    case validatePasswordStrength
    case accountRecoveryFailed(WalletRecoveryError)
    case accountCreation(Result<WalletCreatedContext, WalletCreationServiceError>)
    case accountImported(Result<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError>)
    case walletFetched(Result<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>)
    case informWalletFetched(WalletFetchedContext)
    // required for legacy flow
    case triggerAuthenticate
    case none
}

struct CreateAccountStepTwoEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let checkReferralClient: CheckReferralClientAPI?
    let recaptchaService: GoogleRecaptchaServiceAPI
    let app: AppProtocol?

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        passwordValidator: PasswordValidatorAPI,
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        recaptchaService: GoogleRecaptchaServiceAPI,
        checkReferralClient: CheckReferralClientAPI? = nil,
        app: AppProtocol? = nil
    ) {
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.checkReferralClient = checkReferralClient
        self.recaptchaService = recaptchaService
        self.app = app
    }
}

typealias CreateAccountStepTwoLocalization = LocalizationConstants.FeatureAuthentication.CreateAccount

let createAccountStepTwoReducer = Reducer<
    CreateAccountStepTwoState,
    CreateAccountStepTwoAction,
    CreateAccountStepTwoEnvironment
> { state, action, environment in
    switch action {
    case .binding(\.$emailAddress):
        return EffectTask(value: .didUpdateInputValidation(.unknown))

    case .binding(\.$password):
        return .merge(
            EffectTask(value: .didUpdateInputValidation(.unknown)),
            EffectTask(value: .validatePasswordStrength)
        )

    case .binding(\.$passwordConfirmation):
        guard state.passwordConfirmation.isNotEmpty else {
            state.inputConfirmationValidationState = .unknown
            return .none
        }
        state.inputConfirmationValidationState = state.password != state.passwordConfirmation ? .invalid(.passwordsDontMatch) : .valid
        return .none

    case .binding(\.$termsAccepted):
        return EffectTask(value: .didUpdateInputValidation(.unknown))

    case .binding(\.$bakktTermsAccepted):
        return EffectTask(value: .didUpdateInputValidation(.unknown))

    case .createAccount(.success(let recaptchaToken)):
        // by this point we have validated all the fields neccessary
        state.isCreatingWallet = true
        let accountName = NonLocalizedConstants.defiWalletTitle
        return .merge(
            EffectTask(value: .triggerAuthenticate),
            .cancel(id: CreateAccountStepTwoIds.RecaptchaId()),
            environment.walletCreationService
                .createWallet(
                    state.emailAddress,
                    state.password,
                    accountName,
                    recaptchaToken
                )
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: CreateAccountStepTwoIds.CreationId(), cancelInFlight: true)
                .map(CreateAccountStepTwoAction.accountCreation)
        )

    case .createAccount(.failure(let error)):
        state.isCreatingWallet = false
        state.fatalError = UX.Error(
            source: error,
            title: L10n.FatalError.title,
            message: String(describing: error),
            actions: [UX.Action(title: L10n.FatalError.action)]
        )
        return .cancel(id: CreateAccountStepTwoIds.RecaptchaId())
    case .createOrImportWallet(.createWallet):
        guard state.inputValidationState == .valid else {
            return .none
        }

        return environment.recaptchaService.verifyForSignup()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: CreateAccountStepTwoIds.RecaptchaId(), cancelInFlight: true)
            .map(CreateAccountStepTwoAction.createAccount)

    case .createOrImportWallet(.importWallet(let mnemonic)):
        guard state.inputValidationState == .valid else {
            return .none
        }
        return EffectTask(value: .importAccount(mnemonic))

    case .importAccount(let mnemonic):
        state.isCreatingWallet = true
        let accountName = NonLocalizedConstants.defiWalletTitle
        return .merge(
            EffectTask(value: .triggerAuthenticate),
            environment.walletCreationService
                .importWallet(
                    state.emailAddress,
                    state.password,
                    accountName,
                    mnemonic
                )
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: CreateAccountStepTwoIds.ImportId(), cancelInFlight: true)
                .map(CreateAccountStepTwoAction.accountImported)
        )

    case .accountCreation(.failure(let error)),
         .accountImported(.failure(let error)):
        state.isCreatingWallet = false

        guard error.walletCreateError != .accountCreationFailure else {
            state.fatalError = UX.Error(
                source: error,
                title: L10n.FatalError.title,
                message: L10n.FatalError.description,
                actions: [UX.Action(title: L10n.FatalError.action)]
            )
            return .merge(
                .cancel(id: CreateAccountStepTwoIds.CreationId()),
                .cancel(id: CreateAccountStepTwoIds.ImportId())
            )
        }

        let message = error.errorDescription ?? error.localizedDescription
        state.fatalError = UX.Error(
            source: error,
            title: L10n.FatalError.title,
            message: message,
            actions: [UX.Action(title: L10n.FatalError.action)]
        )
        return .merge(
            .cancel(id: CreateAccountStepTwoIds.CreationId()),
            .cancel(id: CreateAccountStepTwoIds.ImportId())
        )

    case .accountCreation(.success(let context)),
         .accountImported(.success(.left(let context))):

        return .concatenate(
            EffectTask(value: .triggerAuthenticate),
            environment
                .saveReferral(with: state.referralCode)
                .fireAndForget(),
            .merge(
                .cancel(id: CreateAccountStepTwoIds.CreationId()),
                .cancel(id: CreateAccountStepTwoIds.ImportId()),
                environment
                    .walletCreationService
                    .setResidentialInfo(state.country.id, state.countryState?.id)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                environment.walletCreationService
                    .updateCurrencyForNewWallets(state.country.id, context.guid, context.sharedKey)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                environment.walletFetcherService
                    .fetchWallet(context.guid, context.sharedKey, context.password)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CreateAccountStepTwoAction.walletFetched)
            )
        )

    case .walletFetched(.success(.left(.noValue))):
        // do nothing, this for the legacy JS, to be removed
        return .none

    case .walletFetched(.success(.right(let context))):
        return EffectTask(value: .informWalletFetched(context))

    case .walletFetched(.failure(let error)):
        state.isCreatingWallet = false
        let message = error.errorDescription ?? LocalizationConstants.ErrorAlert.message
        state.fatalError = UX.Error(
            source: error,
            title: L10n.FatalError.title,
            message: message,
            actions: [UX.Action(title: L10n.FatalError.action)]
        )
        return .none

    case .informWalletFetched:
        return .none

    case .accountImported(.success(.right(.noValue))):
        // this will only be true in case of legacy wallet
        return .cancel(id: CreateAccountStepTwoIds.ImportId())

    case .createButtonTapped:
        state.validatingInput = true

        return .concatenate(
            EffectTask(value: .didUpdateInputValidation(environment.validateInputs(state: state))),
            EffectTask(value: .didValidateAfterFormSubmission)
        )

    case .didValidateAfterFormSubmission:
        guard !state.inputValidationState.isInvalid
        else {
            return .none
        }

        return EffectTask(value: .createOrImportWallet(state.context))

    case .didUpdatePasswordRules(let rules):
        state.passwordRulesBreached = rules
        return .none

    case .didUpdateInputValidation(let validationState):
        state.validatingInput = false
        state.inputValidationState = validationState
        state.inputConfirmationValidationState = (state.password != state.passwordConfirmation && state.passwordConfirmation.isNotEmpty) ? .invalid(.passwordsDontMatch) : .valid
        return .none

    case .openExternalLink(let url):
        environment.externalAppOpener.open(url)
        return .none

    case .onWillDisappear:
        return .none

    case .route(let route):
        state.route = route
        return .none

    case .validatePasswordStrength:
        return EffectTask(
            value: CreateAccountStepTwoAction.didUpdatePasswordRules(
                environment
                    .passwordValidator
                    .validate(password: state.password)
            )
        )

    case .accountRecoveryFailed(let error):
        state.isCreatingWallet = false
        state.fatalError = UX.Error(
            source: error,
            title: L10n.FatalError.title,
            message: error.localizedDescription,
            actions: [UX.Action(title: L10n.FatalError.action)]
        )
        return .none

    case .triggerAuthenticate:
        return .none

    case .none:
        return .none

    case .binding:
        return .none

    case .onAppear:
        return .merge(
            environment.app?.publisher(
                for: blockchain.app.configuration.external.trading.areas,
                as: [String].self
            )
            .compactMap { [countryState = state.countryState] element -> Bool? in
                guard let listOfStates = element.value, let stateId = countryState?.id else {
                    return nil
                }
                return listOfStates.contains(stateId)
            }
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map {
                .binding(.set(\.$shouldDisplayBakktTermsAndConditions, $0))
            } ?? .none,

            .fireAndForget { [country = state.country, countryState = state.countryState] in
                environment.app?.state.set(blockchain.user.address.country.code, to: country.id)
                environment.app?.state.set(blockchain.user.address.country.state, to: countryState)
            }
        )
    }
}
.binding()
.analytics()

extension CreateAccountStepTwoEnvironment {

    fileprivate func validateInputs(
        state: CreateAccountStepTwoState
    ) -> CreateAccountStepTwoState.InputValidationState {
        guard state.emailAddress.isEmail else {
            return .invalid(.invalidEmail)
        }
        let didAcceptTerm = state.termsAccepted
        let didAcceptBakktTerms = state.termsAccepted || state.shouldDisplayBakktTermsAndConditions == false
        let errors = passwordValidator.validate(password: state.password)

        guard errors.isEmpty else {
            return .invalid(.weakPassword(errors))
        }

        return didAcceptTerm && didAcceptBakktTerms ? .valid : .invalid(.termsNotAccepted)
    }

    func saveReferral(with code: String) -> EffectTask<Void> {
        if code.isNotEmpty {
            app?.post(value: code, of: blockchain.user.creation.referral.code)
        }
        return .none
    }
}

// MARK: - Private

extension Reducer where
    Action == CreateAccountStepTwoAction,
    State == CreateAccountStepTwoState,
    Environment == CreateAccountStepTwoEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CreateAccountStepTwoState,
                CreateAccountStepTwoAction,
                CreateAccountStepTwoEnvironment
            > { state, action, environment in
                switch action {
                case .createButtonTapped:
                    if case .importWallet = state.context {
                        environment.analyticsRecorder.record(
                            event: .importWalletConfirmed
                        )
                    }
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
