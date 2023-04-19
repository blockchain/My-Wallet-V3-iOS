// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit
import WalletPayloadKit

public enum CreateAccountStepOneRoute: NavigationRoute {
    private typealias LocalizedStrings = LocalizationConstants.Authentication.CountryAndStatePickers

    case countryPicker
    case statePicker
    case createWalletStepTwo

    @ViewBuilder
    public func destination(in store: Store<CreateAccountStepOneState, CreateAccountStepOneAction>) -> some View {
        switch self {
        case .countryPicker:
            WithViewStore(store) { viewStore in
                ModalContainer(
                    title: LocalizedStrings.countriesPickerTitle,
                    subtitle: LocalizedStrings.countriesPickerSubtitle,
                    onClose: { viewStore.send(.set(\.$selectedAddressSegmentPicker, nil)) },
                    content: {
                        CountryPickerView(
                            selectedItem: viewStore.binding(\.$country),
                            items: viewStore.binding(\.$countries)
                        )
                    }
                )
            }

        case .statePicker:
            WithViewStore(store) { viewStore in
                ModalContainer(
                    title: LocalizedStrings.statesPickerTitle,
                    subtitle: LocalizedStrings.statesPickerSubtitle,
                    onClose: { viewStore.send(.set(\.$selectedAddressSegmentPicker, nil)) },
                    content: {
                        StatePickerView(selectedItem: viewStore.binding(\.$countryState))
                    }
                )
            }

        case .createWalletStepTwo:
            IfLetStore(
                store.scope(
                    state: \.createWalletStateStepTwo,
                    action: CreateAccountStepOneAction.createWalletStepTwo
                ),
                then: CreateAccountViewStepTwo.init(store:)
            )
        }
    }
}

public struct CreateAccountStepOneState: Equatable, NavigationState {

    public enum InputValidationError: Equatable {
        case noCountrySelected
        case noCountryStateSelected
        case invalidReferralCode
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
        case referralCode
    }

    enum AddressSegmentPicker: Hashable {
        case country
        case countryState
    }

    public var route: RouteIntent<CreateAccountStepOneRoute>?
    public var createWalletStateStepTwo: CreateAccountStepTwoState?

    public var context: CreateAccountContextStepTwo

    // User Input
    @BindingState public var referralCode: String
    @BindingState public var country: SearchableItem<String>?
    @BindingState public var countryState: SearchableItem<String>?

    @BindingState public var countries: [SearchableItem<String>]

    // Form interaction
    @BindingState public var passwordFieldTextVisible: Bool = false
    @BindingState public var selectedInputField: Field?
    @BindingState var selectedAddressSegmentPicker: AddressSegmentPicker?

    // Validation
    public var validatingInput: Bool = false
    public var inputValidationState: InputValidationState
    public var referralCodeValidationState: InputValidationState
    public var failureAlert: AlertState<CreateAccountStepOneAction>?

    public var isCreatingWallet = false
    public var referralFieldEnabled = false
    public var isGoingToNextStep = false

    var isNextStepButtonDisabled: Bool {
        validatingInput || inputValidationState.isInvalid || isCreatingWallet || referralCodeValidationState.isInvalid
    }

    var shouldDisplayCountryStateField: Bool {
        country?.id.lowercased() == "us"
    }

    public init(
        context: CreateAccountContextStepTwo,
        countries: [SearchableItem<String>] = CountryPickerView.countries,
        states: [SearchableItem<String>] = StatePickerView.usaStates
    ) {
        self.context = context
        self.countries = countries
        self.referralCode = ""
        self.inputValidationState = .unknown
        self.referralCodeValidationState = .unknown
    }
}

public enum CreateAccountStepOneAction: Equatable, NavigationAction, BindableAction {

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case onAppear
    case alert(AlertAction)
    case binding(BindingAction<CreateAccountStepOneState>)
    // use `createAccount` to perform the account creation. this action is fired after the user confirms the details and the input is validated.
    case goToStepTwo
    case nextStepButtonTapped
    case createWalletStepTwo(CreateAccountStepTwoAction)
    case importAccount(_ mnemonic: String)
    case referralFieldIsEnabled(Bool)
    case didValidateAfterFormSubmission
    case didUpdateInputValidation(CreateAccountStepOneState.InputValidationState)
    case didUpdateReferralValidation(CreateAccountStepOneState.InputValidationState)
    case validateReferralCode
    case onWillDisappear
    case accountCreationCancelled
    case route(RouteIntent<CreateAccountStepOneRoute>?)
    case accountRecoveryFailed(WalletRecoveryError)
    case signUpCountriesFetched([Country])
    case accountCreation(Result<WalletCreatedContext, WalletCreationServiceError>)
    case accountImported(Result<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError>)
    case walletFetched(Result<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>)
    case informWalletFetched(WalletFetchedContext)
    // required for legacy flow
    case triggerAuthenticate
    case none
}

struct CreateAccountStepOneEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let signUpCountriesService: SignUpCountriesServiceAPI
    let checkReferralClient: CheckReferralClientAPI?
    let featureFlagsService: FeatureFlagsServiceAPI
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
        signUpCountriesService: SignUpCountriesServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
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
        self.signUpCountriesService = signUpCountriesService
        self.checkReferralClient = checkReferralClient
        self.featureFlagsService = featureFlagsService
        self.recaptchaService = recaptchaService
        self.app = app
    }
}

typealias CreateAccountStepOneLocalization = LocalizationConstants.FeatureAuthentication.CreateAccount

let createAccountStepOneReducer = Reducer.combine(
    createAccountStepTwoReducer
        .optional()
        .pullback(
            state: \.createWalletStateStepTwo,
            action: /CreateAccountStepOneAction.createWalletStepTwo,
            environment: {
                CreateAccountStepTwoEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    featureFlagsService: $0.featureFlagsService,
                    recaptchaService: $0.recaptchaService,
                    app: $0.app
                )
            }
        ),
    Reducer<
        CreateAccountStepOneState,
        CreateAccountStepOneAction,
        CreateAccountStepOneEnvironment
    > { state, action, environment in
        switch action {

        case .binding(\.$referralCode):
            return EffectTask(value: .validateReferralCode)

        case .binding(\.$country):
            return .merge(
                EffectTask(value: .didUpdateInputValidation(.unknown)),
                EffectTask(value: .set(\.$selectedAddressSegmentPicker, nil))
            )

        case .binding(\.$countryState):
            return .merge(
                EffectTask(value: .didUpdateInputValidation(.unknown)),
                EffectTask(value: .set(\.$selectedAddressSegmentPicker, nil))
            )

        case .binding(\.$selectedAddressSegmentPicker):
            guard let selection = state.selectedAddressSegmentPicker else {
                return EffectTask(value: .dismiss())
            }
            state.selectedInputField = nil
            switch selection {
            case .country:
                return .enter(into: .countryPicker, context: .none)
            case .countryState:
                return .enter(into: .statePicker, context: .none)
            }

        case .goToStepTwo:
            guard state.inputValidationState == .valid else {
                return .none
            }
            return EffectTask(value: .navigate(to: .createWalletStepTwo))

        case .validateReferralCode:
            return environment
                .validateReferralInput(code: state.referralCode)
                .map(CreateAccountStepOneAction.didUpdateReferralValidation)
                .receive(on: environment.mainQueue)
                .eraseToEffect()

        case .nextStepButtonTapped:
            state.isGoingToNextStep = true
            state.validatingInput = true
            state.selectedInputField = nil

            return .concatenate(
                environment
                    .validateInputs(state: state)
                    .map(CreateAccountStepOneAction.didUpdateInputValidation)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect(),

                environment
                    .featureFlagsService.isEnabled(.referral)
                    .flatMap { [state] isEnabled -> EffectTask<CreateAccountStepOneAction> in
                        guard isEnabled == true else {
                            return .none
                        }
                        return environment
                            .checkReferralCode(state.referralCode)
                            .map(CreateAccountStepOneAction.didUpdateReferralValidation)
                            .receive(on: environment.mainQueue)
                            .eraseToEffect()
                    }
                    .eraseToEffect(),

                EffectTask(value: .didValidateAfterFormSubmission)
            )

        case .didValidateAfterFormSubmission:
            guard !state.inputValidationState.isInvalid,
                  !state.referralCodeValidationState.isInvalid
            else {
                return .none
            }

            return EffectTask(value: .goToStepTwo)

        case .didUpdateInputValidation(let validationState):
            state.validatingInput = false
            state.inputValidationState = validationState
            return .none

        case .didUpdateReferralValidation(let validationState):
            state.referralCodeValidationState = validationState
            return .none

        case .onWillDisappear:
            if !state.isGoingToNextStep {
                return EffectTask(value: .accountCreationCancelled)
            } else {
                state.isGoingToNextStep = false
                return .none
            }

        case .route(let route):
            guard let routeValue = route?.route else {
                state.createWalletStateStepTwo = nil
                state.route = route
                return .none
            }
            switch routeValue {
            case .createWalletStepTwo:
                guard let country = state.country else {
                    fatalError("Country is nil must never happen")
                }
                state.createWalletStateStepTwo = .init(
                    context: .createWallet,
                    country: country,
                    countryState: state.countryState,
                    referralCode: state.referralCode
                )
            case .countryPicker:
                break
            case .statePicker:
                break
            }
            state.route = route
            return .none

        case .accountRecoveryFailed(let error):
            let title = LocalizationConstants.Errors.error
            let message = error.localizedDescription
            return EffectTask(value: .alert(.show(title: title, message: message)))

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

        case .createWalletStepTwo(.triggerAuthenticate):
            return EffectTask(value: .triggerAuthenticate)

        case .createWalletStepTwo(.importAccount(let mnemonic)):
            return EffectTask(value: .importAccount(mnemonic))

        case .createWalletStepTwo(.walletFetched(let result)):
            return EffectTask(value: .walletFetched(result))

        case .createWalletStepTwo(.informWalletFetched(let context)):
            return EffectTask(value: .informWalletFetched(context))

        case .createWalletStepTwo(.accountCreation(.failure(let error))):
            return .fireAndForget {
                environment.app?.post(
                    event: blockchain.ux.user.authentication.sign.up.did.fail,
                    context: [
                        blockchain.ux.user.authentication.sign.up.did.fail.error: String(describing: error)
                    ]
                )
            }

        case .createWalletStepTwo(.createButtonTapped):
            return .fireAndForget {
                environment.app?.post(event: blockchain.ux.user.authentication.sign.up.create.tap)
            }

        case .createWalletStepTwo(.accountCreation(.success)):
            return .fireAndForget {
                environment.app?.post(event: blockchain.ux.user.authentication.sign.up.did.succeed)
            }

        case .alert(.dismiss):
            state.failureAlert = nil
            return .none

        case .triggerAuthenticate:
            return .none

        case .none:
            return .none

        case .binding:
            return .none

        case .referralFieldIsEnabled(let enabled):
            state.referralFieldEnabled = enabled
            return .none

        case .onAppear:
            return .merge(
                .fireAndForget {
                    environment.app?.post(event: blockchain.ux.user.authentication.sign.up)
                },
                environment
                    .featureFlagsService
                    .isEnabled(.referral)
                    .map(CreateAccountStepOneAction.referralFieldIsEnabled)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect(),
                environment
                    .signUpCountriesService
                    .countries
                    .replaceError(with: [])
                    .map(CreateAccountStepOneAction.signUpCountriesFetched)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
            )

        case .signUpCountriesFetched(let countries):
            if countries.isNotEmpty {
                state.countries = countries
                    .compactMap { country -> SearchableItem? in
                        guard let countryName = Locale.current.localizedString(
                            forRegionCode: country.code
                        ) else { return nil }
                        return SearchableItem(
                            id: country.code,
                            title: countryName
                        )
                    }
                    .sorted {
                        $0.title.localizedCompare($1.title) == .orderedAscending
                    }
            }
            return .none

        case .informWalletFetched:
            return .none

        case .accountCreation,
                .accountImported:
            return .none

        case .createWalletStepTwo:
            return .none

        case .importAccount:
            return .none

        case .walletFetched:
            return .none

        case .accountCreationCancelled:
            return .none
        }
    }
)
.binding()
.analytics()

extension CreateAccountStepOneEnvironment {

    fileprivate func validateInputs(
        state: CreateAccountStepOneState
    ) -> AnyPublisher<CreateAccountStepOneState.InputValidationState, Never> {
        let hasValidCountry = state.country != nil
        let hasValidCountryState = state.countryState != nil || !state.shouldDisplayCountryStateField

        guard hasValidCountry else {
            return .just(.invalid(.noCountrySelected))
        }
        guard hasValidCountryState else {
            return .just(.invalid(.noCountryStateSelected))
        }
        return .just(.valid)
    }

    fileprivate func validateReferralInput(
        code: String
    ) -> AnyPublisher<CreateAccountStepOneState.InputValidationState, Never> {
        guard code.range(
            of: TextRegex.noSpecialCharacters.rawValue,
            options: .regularExpression
        ) != nil else { return .just(.invalid(.invalidReferralCode)) }

        return .just(.unknown)
    }

    fileprivate func checkReferralCode(_
        code: String
    ) -> AnyPublisher<CreateAccountStepOneState.InputValidationState, Never> {
        guard code.isNotEmpty, let client = checkReferralClient else { return .just(.unknown) }
        return client
            .checkReferral(with: code)
            .map { _ in
                CreateAccountStepOneState.InputValidationState.valid
            }
            .catch { _ -> AnyPublisher<CreateAccountStepOneState.InputValidationState, Never> in
                .just(.invalid(.invalidReferralCode))
            }
            .eraseToAnyPublisher()
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
    Action == CreateAccountStepOneAction,
    State == CreateAccountStepOneState,
    Environment == CreateAccountStepOneEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CreateAccountStepOneState,
                CreateAccountStepOneAction,
                CreateAccountStepOneEnvironment
            > { state, action, environment in
                switch action {
                case .accountCreationCancelled:
                    if case .importWallet = state.context {
                        environment.analyticsRecorder.record(
                            event: .importWalletCancelled
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
