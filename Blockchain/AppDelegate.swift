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

        BlockchainSettings.App.shared.enableCertificatePinning = true

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

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        if !AuthenticationCoordinator.shared.isPromptingForBiometricAuthentication {
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        // TODO: migrate code from RootService.m...
        return false
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
        //    [_accountsAndAddressesNavigationController reload];
        //    [sideMenuViewController reload];
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
