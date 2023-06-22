// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppUI
import FeatureDebugUI
import PlatformKit
import ToolKit
import WalletPayloadKit

extension AppEnvironment {

    static var live: AppEnvironment {
        AppEnvironment(
            accountRecoveryService: resolve(),
            alertViewPresenter: resolve(),
            analyticsRecorder: resolve(),
            app: resolve(),
            appStoreOpener: resolve(),
            assetsRemoteService: resolve(),
            backgroundAppHandler: resolve(),
            blockchainSettings: resolve(),
            blurEffectHandler: resolve(),
            buildVersionProvider: Bundle.versionAndBuildNumber,
            cacheSuite: resolve(),
            cardService: resolve(),
            certificatePinner: resolve(),
            coincore: resolve(),
            crashlyticsRecorder: resolve(tag: "CrashlyticsRecorder"),
            credentialsStore: resolve(),
            deeplinkAppHandler: resolve(),
            deeplinkHandler: resolve(),
            deeplinkRouter: resolve(),
            delegatedCustodySubscriptionsService: resolve(),
            deviceInfo: resolve(),
            deviceVerificationService: resolve(),
            erc20CryptoAssetService: resolve(),
            exchangeRepository: ExchangeAccountRepository(),
            externalAppOpener: resolve(),
            fiatCurrencySettingsService: resolve(),
            forgetWalletService: .live(
                forgetWallet: DIKit.resolve()
            ),
            legacyGuidRepository: resolve(),
            legacySharedKeyRepository: resolve(),
            loadingViewPresenter: resolve(),
            mainQueue: .main,
            mobileAuthSyncService: resolve(),
            nabuUserService: resolve(),
            openBanking: resolve(),
            performanceTracing: resolve(),
            pushNotificationsRepository: resolve(),
            reactiveWallet: resolve(),
            recaptchaService: resolve(),
            remoteNotificationServiceContainer: resolve(),
            resetPasswordService: resolve(),
            sharedContainer: .default,
            siftService: resolve(),
            unifiedActivityService: resolve(),
            urlSession: resolve(),
            walletPayloadService: resolve(),
            walletRepoPersistence: resolve(),
            walletService: .live(
                fetcher: DIKit.resolve(),
                recovery: DIKit.resolve()
            ),
            walletStateProvider: .live(
                holder: DIKit.resolve()
            )
        )
    }
}
