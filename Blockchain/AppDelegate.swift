//
//  AppDelegate.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    // NOTE: Xcode automatically creates the file name for each launch image
    /// The overlay shown when the application resigns active state.
    lazy var privacyScreen: UIImageView? = {
        let launchImages = [
            "320x480": "LaunchImage-700",
            "320x568": "LaunchImage-700-568h",
            "375x667": "LaunchImage-800-667h",
            "375x812": "LaunchImage-1100-Portrait-2436h",
            "414x736": "LaunchImage-800-Portrait-736h"
        ]
        let screenWidth = Int(UIScreen.main.bounds.size.width)
        let screenHeight = Int(UIScreen.main.bounds.size.height)
        let key = String(format: "%dx%d", screenWidth, screenHeight)
        if let launchImage = UIImage(named: launchImages[key]!) {
            let imageView = UIImageView(frame: UIScreen.main.bounds)
            imageView.image = launchImage
            imageView.alpha = 0
            return imageView
        }
        return nil
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        let activeCount = UserDefaults.System.integer(forKey: .appBecameActiveCount) // 3
        UserDefaults.System.set(activeCount + 1, forKey: .appBecameActiveCount)
        // MARK: - Global Appearance

        //: Status Bar 
        UIApplication.shared.statusBarStyle = .default

        //: Navigation Bar
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = false
        if #available(iOS 11.0, *) {
            navigationBarAppearance.barTintColor = UIColor(named: "ColorBrandPrimary")
        } else {
            navigationBarAppearance.barTintColor = Constants.Colors.ColorBrandPrimary
        }
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.titleTextAttributes = UINavigationBar.standardTitleTextAttributes

        #if DEBUG
        let envKey = UserDefaults.Keys.environment.rawValue
        let environment = Environment.production.rawValue
        UserDefaults.standard.set(environment, forKey: envKey)

        BlockchainSettings.App.shared.enableCertificatePinning = true

        let securityReminderKey = UserDefaults.DebugKeys.securityReminderTimer.rawValue
        UserDefaults.standard.removeObject(forKey: securityReminderKey)

        let appReviewPromptKey = UserDefaults.DebugKeys.appReviewPromptCount.rawValue
        UserDefaults.standard.removeObject(forKey: appReviewPromptKey)

        let zeroTickerKey = UserDefaults.DebugKeys.simulateZeroTicker.rawValue
        UserDefaults.standard.set(false, forKey: zeroTickerKey)

        let simulateSurgeKey = UserDefaults.DebugKeys.simulateSurge.rawValue
        UserDefaults.standard.set(false, forKey: simulateSurgeKey)

        // Send email when exceptions are caught
        NSSetUncaughtExceptionHandler(HandleException)
        #endif

        // TODO: prevent any other data tasks from executing until cert is pinned
        CertificatePinner.shared.pinCertificate()

        checkForNewInstall()

        AppCoordinator.shared.start()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        if !AuthenticationCoordinator.shared.isPromptingForBiometricAuthentication {
            showPrivacyScreen()
        }
        if let pinEntryViewController = AuthenticationCoordinator.shared.pinEntryViewController, pinEntryViewController.verifyOnly {
            pinEntryViewController.reset()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")

        // Wallet-related background actions

        // TODO: This should be moved into a component that performs actions to the wallet
        // on different lifecycle events (e.g. "WalletAppLifecycleListener")
        let appSettings = BlockchainSettings.App.shared
        let wallet = WalletManager.shared.wallet

        AssetAddressRepository.shared.fetchSwipeToReceiveAddressesIfNeeded()

        NotificationCenter.default.post(name: Constants.NotificationKeys.appEnteredBackground, object: nil)

        wallet.isFetchingTransactions = false
        wallet.isFilteringTransactions = false
        wallet.didReceiveMessageForLastTransaction = false

        WalletManager.shared.closeWebSockets(withCloseCode: .backgroundedApp)

        if wallet.isInitialized() {
            if appSettings.guid != nil && appSettings.sharedKey != nil {
                appSettings.hasEndedFirstSession = true
            }
            WalletManager.shared.close()
        }

        let onboardingSettings = BlockchainSettings.Onboarding.shared
        if onboardingSettings.didFailBiometrySetup && !appSettings.biometryEnabled {
            onboardingSettings.shouldShowBiometrySetup = true
        }

        // UI-related background actions
        ModalPresenter.shared.closeAllModals()

        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)

        AppCoordinator.shared.cleanupOnAppBackgrounded()
        AuthenticationCoordinator.shared.cleanupOnAppBackgrounded()

        // Show pin modal before we close the app so the PIN verify modal gets shown in the list of running apps and immediately after we restart
        if appSettings.isPinSet {
            AuthenticationCoordinator.shared.showPinEntryView()
        }

        NetworkManager.shared.session.reset {
            print("URLSession reset completed.")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")

        BlockchainSettings.App.shared.appBecameActiveCount += 1

        BuySellCoordinator.shared.start()

        if !WalletManager.shared.wallet.isInitialized() {
            if BlockchainSettings.App.shared.guid != nil && BlockchainSettings.App.shared.sharedKey != nil {
                AuthenticationCoordinator.shared.start()
            } else {
                OnboardingCoordinator.shared.start()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        hidePrivacyScreen()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        let urlString = url.absoluteString

        guard BlockchainSettings.App.shared.isPinSet else {
            if "\(Constants.Schemes.blockchainWallet)loginAuthorized" == urlString {
                AuthenticationCoordinator.shared.startManualPairing()
                return true
            }
            return false
        }

        guard let urlScheme = url.scheme else {
            return true
        }

        if urlScheme == Constants.Schemes.blockchainWallet {
            // Redirect from browser to app - do nothing.
            return true
        }

        if urlScheme == Constants.Schemes.blockchain {
            ModalPresenter.shared.closeModal(withTransition: kCATransitionFade)
            return true
        }

        // Handle "bitcoin://" scheme
        if let bitcoinUrlPayload = BitcoinURLPayload(url: url) {

            ModalPresenter.shared.closeModal(withTransition: kCATransitionFade)

            AuthenticationCoordinator.shared.postAuthenticationRoute = .sendCoins

            AppCoordinator.shared.tabControllerManager.setupBitcoinPaymentFromURLHandler(
                withAmountString: bitcoinUrlPayload.amount,
                address: bitcoinUrlPayload.address
            )

            return true
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        PushNotificationManager.shared.processRemoteNotification(
            from: application,
            userInfo: userInfo,
            fetchCompletionHandler: completionHandler
        )
    }

    // MARK: - State Checks

    func checkForNewInstall() {

        let appSettings = BlockchainSettings.App.shared
        let onboardingSettings = BlockchainSettings.Onboarding.shared

        if onboardingSettings.hasSeenUpgradeToHdScreen {
            onboardingSettings.hasSeenUpgradeToHdScreen = false
        }

        guard !onboardingSettings.firstRun else {
            print("This is not the 1st time the user is running the app.")
            return
        }

        onboardingSettings.firstRun = true

        if appSettings.guid != nil && appSettings.sharedKey != nil && !appSettings.isPinSet {
            AlertViewPresenter.shared.alertUserAskingToUseOldKeychain { _ in
                AuthenticationCoordinator.shared.showForgetWalletConfirmAlert()
            }
        }
    }

    // MARK: - Privacy screen

    /// Fades out the privacy overlay and removes it from its superview.
    func hidePrivacyScreen() {
        UIView.animate(withDuration: 0.25, animations: {
            self.privacyScreen?.alpha = 0
        }, completion: { _ in
            self.privacyScreen?.removeFromSuperview()
        })
    }

    func showPrivacyScreen() {
        privacyScreen?.alpha = 1
        UIApplication.shared.keyWindow?.addSubview(privacyScreen!)
    }
}
