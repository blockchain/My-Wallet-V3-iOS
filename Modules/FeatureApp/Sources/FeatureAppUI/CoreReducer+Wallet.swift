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
    case FetchId
    case InitializationId
    case UpgradeId
    case CreateId
    case RestoreId
    case RestoreFailedId
    case AssetInitializationId
    case SecondPasswordId
    case ForegroundInitCheckId
}

public enum WalletAction: Equatable {
    case fetch(password: String)
    case walletFetched(Result<WalletFetchedContext, WalletError>)
    case walletBootstrap(WalletFetchedContext)
    case walletSetup
}

struct WalletReducer: Reducer {

    typealias State = CoreAppState
    typealias Action = CoreAppAction

    let environment: CoreAppEnvironment

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .wallet(.fetch(let password)):
                return .run { send in
                        do {
                            let wallet = try await environment.walletService.fetch(password)
                                .receive(on: environment.mainQueue)
                                .await()
                            await send(.wallet(.walletFetched(.success(wallet))))
                        } catch {
                            await send(.wallet(.walletFetched(.failure(error as! WalletError))))
                        }
                    }
                    .cancellable(id: WalletCancelations.FetchId, cancelInFlight: true)

            case .wallet(.walletFetched(.success(let context))):
                // the cancellations are here because we still call the legacy actions
                // and we need to cancel those operation - (remove after JS removal)
                return .concatenate(
                    .cancel(id: WalletCancelations.FetchId),
                    Effect.send(.wallet(.walletBootstrap(context))),
                    Effect.send(.wallet(.walletSetup))
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
                    Effect.send(.resetVerificationStatusIfNeeded(
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
                    return Effect.send(.onboarding(.handleMetadataRecoveryAfterAuthentication))
                }
                // decide if we need to set a pin or not
                guard environment.blockchainSettings.isPinSet else {
                    guard state.onboarding?.welcomeState != nil else {
                        return Effect.send(.setupPin)
                    }
                    return .merge(
                        Effect.send(.onboarding(.welcomeScreen(.dismiss()))),
                        Effect.send(.setupPin)
                    )
                }
                return Effect.send(.prepareForLoggedIn)

            case .wallet(.walletFetched(.failure(.initialization(.needsSecondPassword)))):
                // we don't support double encrypted password wallets
                environment.loadingViewPresenter.hide()
                return Effect.send(
                    .onboarding(.informSecondPasswordDetected)
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
                        Effect.send(.alert(alertAction)),
                        .cancel(id: WalletCancelations.FetchId)
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
                    Effect.send(.alert(alertAction)),
                    .cancel(id: WalletCancelations.FetchId),
                    Effect.send(.onboarding(.handleWalletDecryptionError))
                )

            default:
                return .none
            }
        }
    }
}
