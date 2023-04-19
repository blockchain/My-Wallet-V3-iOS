// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import ERC20Kit
import FeatureAppDomain
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UIKit
import WalletPayloadKit

/// Used for canceling publishers
enum WalletCancelations {
    struct FetchId: Hashable {}
    struct InitializationId: Hashable {}
    struct UpgradeId: Hashable {}
    struct CreateId: Hashable {}
    struct RestoreId: Hashable {}
    struct RestoreFailedId: Hashable {}
    struct AssetInitializationId: Hashable {}
    struct SecondPasswordId: Hashable {}
    struct ForegroundInitCheckId: Hashable {}
}

public enum WalletAction: Equatable {
    case fetch(password: String)
    case walletFetched(Result<WalletFetchedContext, WalletError>)
    case walletBootstrap(WalletFetchedContext)
    case walletSetup
}

extension Reducer where State == CoreAppState, Action == CoreAppAction, Environment == CoreAppEnvironment {
    /// Returns a combined reducer that handles all the wallet related actions
    func walletReducer() -> Self {
        combined(
            with: Reducer { state, action, environment in
                switch action {
                case .wallet(.fetch(let password)):
                    return environment.walletService.fetch(password)
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .cancellable(id: WalletCancelations.FetchId(), cancelInFlight: true)
                        .map { CoreAppAction.wallet(.walletFetched($0)) }

                case .wallet(.walletFetched(.success(let context))):
                    // the cancellations are here because we still call the legacy actions
                    // and we need to cancel those operation - (remove after JS removal)
                    return .concatenate(
                        .cancel(id: WalletCancelations.FetchId()),
                        EffectTask(value: .wallet(.walletBootstrap(context))),
                        EffectTask(value: .wallet(.walletSetup))
                    )

                case .wallet(.walletBootstrap(let context)):
                    // set `guid/sharedKey` (need to refactor this after JS removal)
                    environment.legacyGuidRepository.directSet(guid: context.guid)
                    environment.legacySharedKeyRepository.directSet(sharedKey: context.sharedKey)
                    // `passwordPartHash` is set after Pin creation
                    clearPinIfNeeded(
                        for: context.passwordPartHash,
                        appSettings: environment.blockchainSettings
                    )
                    return .merge(
                        // reset KYC verification if decrypted wallet under recovery context
                        EffectTask(value: .resetVerificationStatusIfNeeded(
                            guid: context.guid,
                            sharedKey: context.sharedKey
                        ))
                    )

                case .wallet(.walletSetup):
                    // decide if we need to reset password or not (we need to reset password after metadata recovery)
                    // if needed, go to reset password screen, if not, go to PIN screen
                    if let context = state.onboarding?.walletRecoveryContext,
                       context == .metadataRecovery
                    {
                        environment.loadingViewPresenter.hide()
                        return EffectTask(value: .onboarding(.handleMetadataRecoveryAfterAuthentication))
                    }
                    // decide if we need to set a pin or not
                    guard environment.blockchainSettings.isPinSet else {
                        guard state.onboarding?.welcomeState != nil else {
                            return EffectTask(value: .setupPin)
                        }
                        return .merge(
                            EffectTask(value: .onboarding(.welcomeScreen(.dismiss()))),
                            EffectTask(value: .setupPin)
                        )
                    }
                    return EffectTask(value: .prepareForLoggedIn)

                case .wallet(.walletFetched(.failure(.initialization(.needsSecondPassword)))):
                    // we don't support double encrypted password wallets
                    environment.loadingViewPresenter.hide()
                    return EffectTask(
                        value: .onboarding(.informSecondPasswordDetected)
                    )

                case .wallet(.walletFetched(.failure(.decryption(.decryptionError)))) where state.onboarding?.pinState != nil:
                    // we need to handle this change since a decryption error might happen when password has changed
                    if let pinState = state.onboarding?.pinState, pinState.requiresPinAuthentication {
                        // hide loader if any
                        environment.loadingViewPresenter.hide()

                        let buttons: CoreAlertAction.Buttons = .init(
                            primary: .destructive(
                                TextState(verbatim: LocalizationConstants.WalletPayloadKit.PasswordChangeAlert.logOutButtonTitle),
                                action: .send(.onboarding(.pin(.logout)))
                            ),
                            secondary: nil
                        )
                        let alertAction = CoreAlertAction.show(
                            title: LocalizationConstants.WalletPayloadKit.PasswordChangeAlert.passwordRequiredTitle,
                            message: LocalizationConstants.WalletPayloadKit.PasswordChangeAlert.passwordRequiredMessage,
                            buttons: buttons
                        )
                        return .merge(
                            EffectTask(value: .alert(alertAction)),
                            .cancel(id: WalletCancelations.FetchId())
                        )
                    }
                    return .none

                case .wallet(.walletFetched(.failure(let error))):
                    // hide loader if any
                    environment.loadingViewPresenter.hide()
                    // show alert
                    let buttons: CoreAlertAction.Buttons = .init(
                        primary: .default(
                            TextState(verbatim: LocalizationConstants.ErrorAlert.button),
                            action: .send(.alert(.dismiss))
                        ),
                        secondary: nil
                    )
                    let alertAction = CoreAlertAction.show(
                        title: LocalizationConstants.Errors.error,
                        message: error.errorDescription ?? LocalizationConstants.Errors.genericError,
                        buttons: buttons
                    )
                    return .merge(
                        EffectTask(value: .alert(alertAction)),
                        .cancel(id: WalletCancelations.FetchId()),
                        EffectTask(value: .onboarding(.handleWalletDecryptionError))
                    )

                default:
                    return .none
                }
            }
        )
    }
}
