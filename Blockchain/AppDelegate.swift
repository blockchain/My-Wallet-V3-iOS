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

    lazy var busyView: BCFadeView? = {
        guard let windowFrame = UIApplication.shared.keyWindow?.frame else {
            return BCFadeView(frame: UIScreen.main.bounds)
        }
        print(windowFrame)
        return BCFadeView(frame: windowFrame)
    }()

    /// The overlay shown when the application resigns active state.
    lazy var privacyScreen: UIImageView? = {
        let launchImages = [
            "320x480": "LaunchImage-700",
            "320x568": "LaunchImage-700-568h",
            "375x667": "LaunchImage-800-667h",
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

        //: Global appearance customizations
        UIApplication.shared.statusBarStyle = .default

        #if DEBUG
        let envKey = UserDefaults.Keys.environment.rawValue
        let environment = Environment.production.rawValue
        UserDefaults.standard.set(environment, forKey: envKey)

        BlockchainSettings.App.shared.enableCertificatePinning = true

        let securityReminderKey = UserDefaults.DebugKeys.securityReminderTimer.rawValue
        UserDefaults.standard.removeObject(forKey: securityReminderKey)

        let appReviewPromptKey = UserDefaults.DebugKeys.appReviewPromptTimer.rawValue
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
        wallet.setupBuySellWebview()

        WalletManager.shared.closeWebSockets(withCloseCode: .backgroundedApp)

        if wallet.isInitialized() {
            if appSettings.guid != nil && appSettings.sharedKey != nil {
                appSettings.hasEndedFirstSession = true
            }
            WalletManager.shared.close()
        }

        if appSettings.hasSeenAllCards {
            appSettings.shouldHideAllCards = true
        }

        if appSettings.didFailTouchIDSetup && !appSettings.touchIDEnabled {
            appSettings.shouldShowTouchIDSetup = true
        }

        // UI-related background actions
        ModalPresenter.shared.closeAllModals()

        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)

        AppCoordinator.shared.cleanupOnAppBackgrounded()
        AuthenticationCoordinator.shared.cleanupOnAppBackgrounded()

        // Show pin modal before we close the app so the PIN verify modal gets shown in the list of running apps and immediately after we restart
        if appSettings.isPinSet {
            AuthenticationCoordinator.shared.showPinEntryView(asModal: true)
        }

        NetworkManager.shared.session.reset {
            print("URLSession reset completed.")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
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

    func applicationWillTerminate(_ application: UIApplication) {
        let appSettings = BlockchainSettings.App.shared
        appSettings.shouldHideAllCards = true
        appSettings.hasSeenAllCards = true
        appSettings.shouldHideBuySellCard = true
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
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
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

        //        if UserDefaults.standard.object(forKey: upgradeKey) != nil {
        //            UserDefaults.standard.removeObject(forKey: upgradeKey)
        //        }
        // TODO: investigate this further
        if appSettings.hasSeenUpgradeToHdScreen {
            appSettings.hasSeenUpgradeToHdScreen = false
        }

        guard !appSettings.firstRun else {
            print("This is not the 1st time the user is running the app.")
            return
        }

        appSettings.firstRun = true

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

    //: These two functions are used to justify the regeneration of addresses in the swipe-to-receive screen.
    // NOTE: Ethereum does not apply here, because the address is currently not regenerated.

    // TODO: move to appropriate controller
    func checkForUnusedAddress(_ address: AssetAddress,
                               successHandler: @escaping ((_ isUnused: Bool) -> Void),
                               errorHandler: @escaping ((_ error: Error) -> Void)) {
        guard
            let urlString = BlockchainAPI.shared.suffixURL(address: address),
            let url = URL(string: urlString) else {
                return
        }
        NetworkManager.shared.session.sessionDescription = url.host
        let task = NetworkManager.shared.session.dataTask(with: url, completionHandler: { data, _, error in
            if let error = error {
                DispatchQueue.main.async { errorHandler(error) }; return
            }
            guard
                let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
                let transactions = json!["txs"] as? [NSDictionary] else {
                    // TODO: call error handler
                    return
            }
            DispatchQueue.main.async {
                let isUnused = transactions.count == 0
                successHandler(isUnused)
            }
        })
        task.resume()
    }
}
