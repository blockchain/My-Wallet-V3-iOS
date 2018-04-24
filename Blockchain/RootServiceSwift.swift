//
//  RootService.swift
//  Blockchain
//
//  Created by Maurice A. on 2/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
//  Swift implementation of the Root Service

import Foundation

// TODO: rename RootServiceSwift -> RootService once migration is complete

final class RootServiceSwift {

    // MARK: - Properties

    /// Grants the Root Service access to the application delegate
    fileprivate let appDelegate: AppDelegate!

    /// Flag used to indicate whether the device is prompting for biometric authentication.
    @objc public private(set) var isPromptingForBiometricAuthentication = false

    /// The instance variable used to access functions of the `RootServiceSwift` class.
    static let shared = RootServiceSwift()

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

    // MARK: Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private init() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("No application delegate found!")
        }
        appDelegate = delegate
    }

    // MARK: - Application Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        print("applicationDidFinishLaunchingWithOptions")

        //: Global appearance customizations
        UIApplication.shared.statusBarStyle = .default

        //: Was initialized with `NSNumber numberWithInt:AssetTypeBitcoin` before, could cause side unwanted effects...
        // TODO: test for potential side effects
        let assetTypekey = UserDefaults.Keys.assetType.rawValue
        UserDefaults.standard.register(defaults: [assetTypekey: AssetType.bitcoin.rawValue])

        let certPinningkey = UserDefaults.DebugKeys.enableCertificatePinning.rawValue
        UserDefaults.standard.register(defaults: [certPinningkey: true])

        let swipeToReceiveEnabledKey = UserDefaults.Keys.swipeToReceiveEnabled.rawValue
        UserDefaults.standard.register(defaults: [swipeToReceiveEnabledKey: true])

        #if DEBUG
        let envKey = UserDefaults.Keys.environment.rawValue
        let environment = Environment.production.rawValue
        UserDefaults.standard.set(environment, forKey: envKey)

        UserDefaults.standard.set(true, forKey: certPinningkey)

        let securityReminderKey = UserDefaults.DebugKeys.securityReminderTimer.rawValue
        UserDefaults.standard.removeObject(forKey: securityReminderKey)

        let appReviewPromptKey = UserDefaults.DebugKeys.appReviewPromptTimer.rawValue
        UserDefaults.standard.removeObject(forKey: appReviewPromptKey)

        let zeroTickerKey = UserDefaults.DebugKeys.simulateZeroTicker.rawValue
        UserDefaults.standard.set(false, forKey: zeroTickerKey)

        let simulateSurgeKey = UserDefaults.DebugKeys.simulateSurge.rawValue
        UserDefaults.standard.set(false, forKey: simulateSurgeKey)
        #endif

        CertificatePinner.shared.pinCertificate()

        checkForNewInstall()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        self.hidePrivacyScreen()
        UIApplication.shared.applicationIconBadgeNumber = 0
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return false
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
                app.wallet.apiGetPINValue(pinKey, pin: pin)
            }
        }
    }

    // TODO: migrate to the responsible controller that prompts for authentication
    func handleBiometricAuthenticationError(with error: AuthenticationError) {
        if let description = error.description {
            let alert = UIAlertController(title: LCStringError, message: description, preferredStyle: .alert)
            let action = UIAlertAction(title: LCStringOK, style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                app.window.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    // TODO: migrate to the responsible controller that prompts for authentication
    func handlePasscodeAuthenticationError(with error: AuthenticationError) {
        // TODO: implement handlePasscodeAuthenticationError
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
        app.window.addSubview(privacyScreen!)
    }

    func failedToObtainValuesFromKeychain() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "", style: .cancel, handler: { _ in
            // let app = UIApplication.shared
            // perform suspend selector
        })
        alert.addAction(action)
        app.window.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func showVerifyingBusyView(withTimeout seconds: Int) {
        app.showBusyView(withLoadingText: LCStringLoadingVerifying)
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
        // TODO: complete showErrorLoading implementation
        if let timer = loginTimeout {
            timer.invalidate()
        }
//        if (!self.wallet.guid && busyView.alpha == 1.0 && [busyLabel.text isEqualToString:BC_STRING_LOADING_VERIFYING]) {
//            [self.pinEntryViewController reset];
//            [self hideBusyView];
//            [self standardNotifyAutoDismissingController:BC_STRING_ERROR_LOADING_WALLET];
//        }
    }

    // MARK: - State Checks

    // TODO: move to BlockchainSettings
    func checkForNewInstall() {
        if !BlockchainSettings.App.shared.firstRun {
            if KeychainItemWrapper.guid() != nil && KeychainItemWrapper.sharedKey() != nil && !BlockchainSettings.sharedAppInstance().isPinSet {
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
}
