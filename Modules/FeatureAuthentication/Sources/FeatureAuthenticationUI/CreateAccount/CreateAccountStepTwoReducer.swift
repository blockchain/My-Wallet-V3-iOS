// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import ErrorsUI
import FeatureAuthenticationDomain
import Foundation
import Localization
import Security
import SwiftUI
import ToolKit
import UIComponentsKit
import WalletPayloadKit

private let domain = "blockchain.com" as CFString
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
            mnemonic
        case .createWallet:
            nil
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
                true
            case .valid, .unknown:
                false
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
    case saveToCloud
    // required for legacy flow
    case triggerAuthenticate
    case none
}

typealias CreateAccountStepTwoLocalization = LocalizationConstants.FeatureAuthentication.CreateAccount

struct CreateAccountStepTwoReducer: Reducer {

    typealias State = CreateAccountStepTwoState
    typealias Action = CreateAccountStepTwoAction

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

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$emailAddress):
                return Effect.send(.didUpdateInputValidation(.unknown))

            case .binding(\.$password):
                return .merge(
                    Effect.send(.didUpdateInputValidation(.unknown)),
                    Effect.send(.validatePasswordStrength)
                )

            case .binding(\.$passwordConfirmation):
                guard state.passwordConfirmation.isNotEmpty else {
                    state.inputConfirmationValidationState = .unknown
                    return .none
                }
                state.inputConfirmationValidationState = state.password != state.passwordConfirmation ? .invalid(.passwordsDontMatch) : .valid
                return .none

            case .binding(\.$bakktTermsAccepted):
                return Effect.send(.didUpdateInputValidation(.unknown))

            case .createAccount(.success(let recaptchaToken)):
                // by this point we have validated all the fields neccessary
                state.isCreatingWallet = true
                let accountName = NonLocalizedConstants.defiWalletTitle
                return .merge(
                    Effect.send(.triggerAuthenticate),
                    .cancel(id: CreateAccountStepTwoIds.RecaptchaId()),
                    Effect.publisher { [state] in
                        walletCreationService
                            .createWallet(
                                state.emailAddress,
                                state.password,
                                accountName,
                                recaptchaToken
                            )
                            .receive(on: mainQueue)
                            .map { .accountCreation(.success($0)) }
                            .catch { .accountCreation(.failure($0)) }
                    }
                    .cancellable(id: CreateAccountStepTwoIds.CreationId(), cancelInFlight: true)
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

                return .publisher {
                    recaptchaService.verifyForSignup()
                        .receive(on: mainQueue)
                        .map { .createAccount(.success($0)) }
                        .catch { .createAccount(.failure($0)) }
                }
                .cancellable(id: CreateAccountStepTwoIds.RecaptchaId(), cancelInFlight: true)

            case .createOrImportWallet(.importWallet(let mnemonic)):
                guard state.inputValidationState == .valid else {
                    return .none
                }
                return Effect.send(.importAccount(mnemonic))

            case .importAccount(let mnemonic):
                state.isCreatingWallet = true
                let accountName = NonLocalizedConstants.defiWalletTitle
                return .merge(
                    Effect.send(.triggerAuthenticate),
                    Effect.publisher { [emailAddress = state.emailAddress, password = state.password] in
                        walletCreationService
                            .importWallet(
                                emailAddress,
                                password,
                                accountName,
                                mnemonic
                            )
                            .receive(on: mainQueue)
                            .map { .accountImported(.success($0)) }
                            .catch { .accountImported(.failure($0)) }
                    }
                    .cancellable(id: CreateAccountStepTwoIds.ImportId(), cancelInFlight: true)
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
                    Effect.send(.triggerAuthenticate),
                    Effect.send(.saveToCloud),
                    saveReferral(with: state.referralCode),
                    .merge(
                        .cancel(id: CreateAccountStepTwoIds.CreationId()),
                        .cancel(id: CreateAccountStepTwoIds.ImportId()),
                        .run { [countryId = state.country.id] _ in
                            do {
                                try await walletCreationService
                                    .updateCurrencyForNewWallets(countryId, context.guid, context.sharedKey)
                                    .receive(on: mainQueue)
                                    .await()
                            }
                        },
                        .publisher {
                            walletFetcherService
                                .fetchWallet(context.guid, context.sharedKey, context.password)
                                .receive(on: mainQueue)
                                .map { .walletFetched(.success($0)) }
                                .catch { .walletFetched(.failure($0)) }
                        }
                    )
                )

            case .walletFetched(.success(.left(.noValue))):
                // do nothing, this for the legacy JS, to be removed
                return .none

            case .walletFetched(.success(.right(let context))):
                return Effect.send(.informWalletFetched(context))

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
                app?.post(event: blockchain.ux.user.authentication.sign.up.address.submit)
                return .none

            case .accountImported(.success(.right(.noValue))):
                // this will only be true in case of legacy wallet
                return .cancel(id: CreateAccountStepTwoIds.ImportId())

            case .createButtonTapped:
                state.validatingInput = true

                if case .importWallet = state.context {
                    analyticsRecorder.record(
                        event: .importWalletConfirmed
                    )
                }

                return .concatenate(
                    Effect.send(.didUpdateInputValidation(validateInputs(state: state))),
                    Effect.send(.didValidateAfterFormSubmission)
                )

            case .didValidateAfterFormSubmission:
                guard !state.inputValidationState.isInvalid
                else {
                    return .none
                }

                return Effect.send(.createOrImportWallet(state.context))

            case .didUpdatePasswordRules(let rules):
                state.passwordRulesBreached = rules
                return .none

            case .didUpdateInputValidation(let validationState):
                state.validatingInput = false
                state.inputValidationState = validationState
                state.inputConfirmationValidationState = (state.password != state.passwordConfirmation && state.passwordConfirmation.isNotEmpty) ? .invalid(.passwordsDontMatch) : .valid
                return .none

            case .openExternalLink(let url):
                externalAppOpener.open(url)
                return .none

            case .onWillDisappear:
                return .none

            case .route(let route):
                state.route = route
                return .none

            case .validatePasswordStrength:
                return Effect.send(
                    CreateAccountStepTwoAction.didUpdatePasswordRules(
                        passwordValidator.validate(password: state.password)
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

            case .saveToCloud:
                if BuildFlag.isAlpha || BuildFlag.isProduction {
                    SecAddSharedWebCredential(
                        domain,
                        state.emailAddress as CFString,
                        state.password as CFString?,
                        { _ in }
                    )
                }
                return .none

            case .triggerAuthenticate:
                return .none

            case .none:
                return .none

            case .binding:
                return .none

            case .onAppear:
                return .merge(
                    .run { [country = state.country, countryState = state.countryState] send in
                        let isExternalTrading = try await app?.publisher(
                            for: blockchain.app.configuration.external.trading.areas,
                            as: [String].self
                        )
                        .compactMap { element -> Bool? in
                            guard let listOfStates = element.value, let stateId = countryState?.id else {
                                return nil
                            }
                            return listOfStates.contains("\(country.id)-\(stateId)")
                        }
                        .await()

                        if let isExternalTrading {
                            await send(.binding(.set(\.$shouldDisplayBakktTermsAndConditions, isExternalTrading)))
                        }
                    },

                    .run { [country = state.country, countryState = state.countryState] _ in
                        app?.state.set(blockchain.user.address.country.code, to: country.id)
                        app?.state.set(blockchain.user.address.country.state, to: countryState)
                    }
                )
            }
        }
    }
}

extension CreateAccountStepTwoReducer {
    private func validateInputs(
        state: CreateAccountStepTwoState
    ) -> CreateAccountStepTwoState.InputValidationState {
        guard state.emailAddress.isEmail else {
            return .invalid(.invalidEmail)
        }
        let didAcceptBakktTerms = state.shouldDisplayBakktTermsAndConditions == false || state.bakktTermsAccepted
        let errors = passwordValidator.validate(password: state.password)

        guard errors.isEmpty else {
            return .invalid(.weakPassword(errors))
        }

        return didAcceptBakktTerms ? .valid : .invalid(.termsNotAccepted)
    }

    func saveReferral(with code: String) -> Effect<CreateAccountStepTwoAction> {
        if code.isNotEmpty {
            app?.post(value: code, of: blockchain.user.creation.referral.code)
        }
        return .none
    }
}
