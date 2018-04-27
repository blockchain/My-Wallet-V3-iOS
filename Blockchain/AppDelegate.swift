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

    // TODO: move to authentication flow
    /// Flag used to indicate whether the device is prompting for biometric authentication.
    @objc public private(set) var isPromptingForBiometricAuthentication = false

    fileprivate var loginTimeout: Timer?

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

//        let assetTypekey = UserDefaults.Keys.assetType.rawValue
//        UserDefaults.standard.register(defaults: [assetTypekey: AssetType.bitcoin.rawValue])

//        let certPinningkey = UserDefaults.DebugKeys.enableCertificatePinning.rawValue
//        UserDefaults.standard.register(defaults: [certPinningkey: true])

//        let swipeToReceiveEnabledKey = UserDefaults.Keys.swipeToReceiveEnabled.rawValue
//        UserDefaults.standard.register(defaults: [swipeToReceiveEnabledKey: true])

        #if DEBUG
        let envKey = UserDefaults.Keys.environment.rawValue
        let environment = Environment.production.rawValue
        UserDefaults.standard.set(environment, forKey: envKey)

        BlockchainSettings.sharedAppInstance().enableCertificatePinning = true

        let securityReminderKey = UserDefaults.DebugKeys.securityReminderTimer.rawValue
        UserDefaults.standard.removeObject(forKey: securityReminderKey)

        let appReviewPromptKey = UserDefaults.DebugKeys.appReviewPromptTimer.rawValue
        UserDefaults.standard.removeObject(forKey: appReviewPromptKey)

        let zeroTickerKey = UserDefaults.DebugKeys.simulateZeroTicker.rawValue
        UserDefaults.standard.set(false, forKey: zeroTickerKey)

        let simulateSurgeKey = UserDefaults.DebugKeys.simulateSurge.rawValue
        UserDefaults.standard.set(false, forKey: simulateSurgeKey)
        #endif

        // TODO: prevent any other data tasks from executing until cert is pinned
        CertificatePinner.shared.pinCertificate()

        checkForNewInstall()

        AppCoordinator.shared.start()

        if #available(iOS 10.0, *) {
            PushNotificationManager.shared.requestAuthorization()
        } else {
            LegacyPushNotificationManager.shared.requestAuthorization()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        if !isPromptingForBiometricAuthentication {
            showPrivacyScreen()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        hidePrivacyScreen()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    // MARK: - Authentication

    @objc func authenticateWithBiometrics() {
        app.pinEntryViewController.view.isUserInteractionEnabled = false
        isPromptingForBiometricAuthentication = true
        AuthenticationManager.shared.authenticateUsingBiometrics { authenticated, authenticationError in
            self.isPromptingForBiometricAuthentication = false
            if let error = authenticationError {
                self.handleBiometricAuthenticationError(with: error)
            }
            DispatchQueue.main.async {
                app.pinEntryViewController.view.isUserInteractionEnabled = true
            }
            if authenticated {
                DispatchQueue.main.async {
                    self.showVerifyingBusyView(withTimeout: 30)
                }
                guard let pinKey = BlockchainSettings.App.shared.pinKey,
                    let pin = KeychainItemWrapper.pinFromKeychain() else {
                        self.failedToObtainValuesFromKeychain(); return
                }
                WalletManager.shared.wallet.apiGetPINValue(pinKey, pin: pin)
            }
        }
    }

    // TODO: migrate to the responsible controller that prompts for authentication
    func handleBiometricAuthenticationError(with error: AuthenticationError) {
        if let description = error.description {
            let alert = UIAlertController(title: LocalizationConstants.error, message: description, preferredStyle: .alert)
            let action = UIAlertAction(title: LocalizationConstants.ok, style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    // TODO: migrate to the responsible controller that prompts for authentication
    func handlePasscodeAuthenticationError(with error: AuthenticationError) {
        // TODO: implement handlePasscodeAuthenticationError
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        // TODO: migrate code from RootService.m...
        return false
    }

    func showVerifyingBusyView(withTimeout seconds: Int) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.verifying)
        // TODO: refactor showVerifyingBusyView with newer iOS 10+ method
        loginTimeout = Timer.scheduledTimer(
            timeInterval: TimeInterval(seconds),
            target: self,
            selector: #selector(showErrorLoading),
            userInfo: nil,
            repeats: false
        )
    }
    @objc func showErrorLoading() {
        // TODO: put this in AuthenticationManager
        if let timer = loginTimeout {
            timer.invalidate()
        }
        //        if (!self.wallet.guid && busyView.alpha == 1.0 && [busyLabel.text isEqualToString:BC_STRING_LOADING_VERIFYING]) {
        //            [self.pinEntryViewController reset];
        //            [self hideBusyView];
        //            [self standardNotifyAutoDismissingController:BC_STRING_ERROR_LOADING_WALLET];
        //        }
    }

    // TODO: move to appropriate module
    func toggleSymbol() {
        let symbolLocal = BlockchainSettings.App.shared.symbolLocal
        BlockchainSettings.App.shared.symbolLocal = !symbolLocal
        reloadSymbols()
    }

    // TODO: don't keep a reference to each contoller, instead allow them to subscribe to value changes
    func reloadSymbols() {
        //    [self.tabControllerManager reloadSymbols];
        //    [_contactsViewController reloadSymbols];
        //    [_accountsAndAddressesNavigationController reload];
        //    [sideMenuViewController reload];
    }

    // MARK: - State Checks

    // TODO: move to BlockchainSettings
    func checkForNewInstall() {
        if !BlockchainSettings.App.shared.firstRun {
            if BlockchainSettings.App.shared.guid != nil &&
                BlockchainSettings.App.shared.sharedKey != nil &&
                !BlockchainSettings.sharedAppInstance().isPinSet {
                alertUserAskingToUseOldKeychain()
            }
            BlockchainSettings.App.shared.firstRun = true
        }
        //        if UserDefaults.standard.object(forKey: upgradeKey) != nil {
        //            UserDefaults.standard.removeObject(forKey: upgradeKey)
        //        }
        // TODO: investigate this further
        if BlockchainSettings.App.shared.hasSeenUpgradeToHdScreen {
            BlockchainSettings.App.shared.hasSeenUpgradeToHdScreen = false
        }
    }

    func alertUserAskingToUseOldKeychain() {
        // TODO: implement alertUserAskingToUseOldKeychain
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

    func failedToObtainValuesFromKeychain() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "", style: .cancel, handler: { _ in
            // let app = UIApplication.shared
            // perform suspend selector
        })
        alert.addAction(action)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
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
