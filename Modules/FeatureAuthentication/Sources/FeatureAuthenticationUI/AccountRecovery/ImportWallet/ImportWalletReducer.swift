// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

public enum ImportWalletAction: Equatable {
    case importWalletButtonTapped
    case goBackButtonTapped
    case setCreateAccountScreenVisible(Bool)
    case createAccount(CreateAccountStepOneAction)
    case importWalletFailed(WalletRecoveryError)
}

struct ImportWalletState: Equatable {
    var mnemonic: String
    var createAccountState: CreateAccountStepOneState?
    var isCreateAccountScreenVisible: Bool

    init(mnemonic: String) {
        self.mnemonic = mnemonic
        self.isCreateAccountScreenVisible = false
    }
}

struct ImportWalletEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let signUpCountriesService: SignUpCountriesServiceAPI
    let featureFlagsService: FeatureFlagsServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let app: AppProtocol
}

let importWalletReducer = Reducer.combine(
    createAccountStepOneReducer
        .optional()
        .pullback(
            state: \.createAccountState,
            action: /ImportWalletAction.createAccount,
            environment: {
                CreateAccountStepOneEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService,
                    signUpCountriesService: $0.signUpCountriesService,
                    featureFlagsService: $0.featureFlagsService,
                    recaptchaService: $0.recaptchaService,
                    app: $0.app
                )
            }
        ),
    Reducer<
        ImportWalletState,
        ImportWalletAction,
        ImportWalletEnvironment
    > { state, action, environment in
        switch action {
        case .setCreateAccountScreenVisible(let isVisible):
            state.isCreateAccountScreenVisible = isVisible
            if isVisible {
                state.createAccountState = .init(
                    context: .importWallet(mnemonic: state.mnemonic)
                )
            }
            return .none
        case .importWalletButtonTapped:
            environment.analyticsRecorder.record(
                event: .importWalletClicked
            )
            return EffectTask(value: .setCreateAccountScreenVisible(true))
        case .goBackButtonTapped:
            environment.analyticsRecorder.record(
                event: .importWalletCancelled
            )
            return .none
        case .importWalletFailed(let error):
            guard state.createAccountState != nil else {
                return .none
            }
            return EffectTask(value: .createAccount(.accountRecoveryFailed(error)))
        case .createAccount:
            return .none
        }
    }
)
