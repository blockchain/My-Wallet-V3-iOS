// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
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

struct ImportWalletReducer: Reducer {

    typealias State = ImportWalletState
    typealias Action = ImportWalletAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let signUpCountriesService: SignUpCountriesServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let app: AppProtocol

    var body: some Reducer<State, Action> {
        Reduce { state, action in
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
                analyticsRecorder.record(
                    event: .importWalletClicked
                )
                return Effect.send(.setCreateAccountScreenVisible(true))
            case .goBackButtonTapped:
                analyticsRecorder.record(
                    event: .importWalletCancelled
                )
                return .none
            case .importWalletFailed(let error):
                guard state.createAccountState != nil else {
                    return .none
                }
                return Effect.send(.createAccount(.accountRecoveryFailed(error)))
            case .createAccount:
                return .none
            }
        }
        .ifLet(\.createAccountState, action: /ImportWalletAction.createAccount) {
            CreateAccountStepOneReducer(
                mainQueue: mainQueue,
                passwordValidator: passwordValidator,
                externalAppOpener: externalAppOpener,
                analyticsRecorder: analyticsRecorder,
                walletRecoveryService: walletRecoveryService,
                walletCreationService: walletCreationService,
                walletFetcherService: walletFetcherService,
                signUpCountriesService: signUpCountriesService,
                recaptchaService: recaptchaService,
                app: app
            )
        }
    }
}
