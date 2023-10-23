// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import ToolKit
import WalletPayloadKit

// MARK: - Type

private enum PasswordRequiredCancellations {
    struct RequestSharedKeyId: Hashable {}
    struct RevokeTokenId: Hashable {}
    struct UpdateMobileSetupId: Hashable {}
    struct VerifyCloudBackupId: Hashable {}
}

private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.PasswordRequired

public enum PasswordRequiredAction: Equatable, BindableAction {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
        case forgetWallet
    }

    case alert(PresentationAction<AlertAction>)
    case binding(BindingAction<PasswordRequiredState>)
    case start
    case continueButtonTapped
    case authenticate(String)
    case forgetWalletTapped
    case forgotPasswordTapped
    case openExternalLink(URL)
    case none
}

// MARK: - Properties

public struct PasswordRequiredState: Equatable {

    // MARK: - Alert

    @PresentationState var alert: AlertState<PasswordRequiredAction.AlertAction>?

    // MARK: - Constant Info

    public var walletIdentifier: String

    // MARK: - User Input

    @BindingState public var password: String = ""
    @BindingState public var isPasswordVisible: Bool = false
    @BindingState public var isPasswordSelected: Bool = false

    public init(
        walletIdentifier: String
    ) {
        self.walletIdentifier = walletIdentifier
    }
}

public struct PasswordRequiredReducer: Reducer {

    public typealias State = PasswordRequiredState
    public typealias Action = PasswordRequiredAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let externalAppOpener: ExternalAppOpener
    let walletPayloadService: WalletPayloadServiceAPI
    let pushNotificationsRepository: PushNotificationsRepositoryAPI
    let mobileAuthSyncService: MobileAuthSyncServiceAPI
    let forgetWalletService: ForgetWalletService

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        externalAppOpener: ExternalAppOpener,
        walletPayloadService: WalletPayloadServiceAPI,
        pushNotificationsRepository: PushNotificationsRepositoryAPI,
        mobileAuthSyncService: MobileAuthSyncServiceAPI,
        forgetWalletService: ForgetWalletService
    ) {
        self.mainQueue = mainQueue
        self.externalAppOpener = externalAppOpener
        self.walletPayloadService = walletPayloadService
        self.pushNotificationsRepository = pushNotificationsRepository
        self.mobileAuthSyncService = mobileAuthSyncService
        self.forgetWalletService = forgetWalletService
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .alert(.presented(.show(let title, let message))):
                state.alert = AlertState(
                    title: TextState(verbatim: title),
                    message: TextState(verbatim: message),
                    dismissButton: .default(
                        TextState(verbatim: LocalizationConstants.okString),
                        action: .send(.dismiss)
                    )
                )
                return .none
            case .alert(.dismiss), .alert(.presented(.dismiss)):
                state.alert = nil
                return .none
            case .binding:
                return .none
            case .start:
                return .none
            case .continueButtonTapped:
                return .run { [password = state.password] send in
                    do {
                        try await walletPayloadService
                            .requestUsingSharedKey()
                            .await()

                        await send(.authenticate(password))
                    } catch {
                        await send(
                            .alert(
                                .presented(
                                    .show(
                                        title: LocalizationConstants.Authentication.failedToLoadWallet,
                                        message: LocalizationConstants.Errors.errorLoadingWalletIdentifierFromKeychain
                                    )
                                )
                            )
                        )
                    }
                }
                .cancellable(id: PasswordRequiredCancellations.RequestSharedKeyId())

            case .authenticate:
                return .none
            case .forgetWalletTapped:
                state.alert = AlertState(
                    title: TextState(verbatim: LocalizedString.ForgetWalletAlert.title),
                    message: TextState(verbatim: LocalizedString.ForgetWalletAlert.message),
                    primaryButton: .destructive(
                        TextState(verbatim: LocalizedString.ForgetWalletAlert.forgetButton),
                        action: .send(.forgetWallet)
                    ),
                    secondaryButton: .cancel(
                        TextState(verbatim: LocalizationConstants.cancel),
                        action: .send(.dismiss)
                    )
                )
                return .none
            case .alert(.presented(.forgetWallet)):
                return .merge(
                    .publisher {
                        forgetWalletService
                            .forget()
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: mainQueue)
                    },
                    .publisher {
                        pushNotificationsRepository
                            .revokeToken()
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: mainQueue)
                    }
                    .cancellable(id: PasswordRequiredCancellations.RevokeTokenId()),
                    .publisher {
                        mobileAuthSyncService
                            .updateMobileSetup(isMobileSetup: false)
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: mainQueue)
                    }
                    .cancellable(id: PasswordRequiredCancellations.UpdateMobileSetupId()),
                    .publisher {
                        mobileAuthSyncService
                            .verifyCloudBackup(hasCloudBackup: false)
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: mainQueue)
                    }
                    .cancellable(id: PasswordRequiredCancellations.VerifyCloudBackupId())
                )
            case .forgotPasswordTapped:
                return .merge(
                    Effect.send(.openExternalLink(
                       URL(string: Constants.HostURL.recoverPassword)!
                    )),
                    Effect.send(.alert(.presented(.forgetWallet)))
                )
            case .openExternalLink(let url):
                externalAppOpener.open(url)
                return .none
            case .none:
                return .none
            }
        }
    }
}
