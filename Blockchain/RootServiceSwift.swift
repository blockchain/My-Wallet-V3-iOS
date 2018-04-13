//
//  RootService.swift
//  Blockchain
//
//  Created by Maurice A. on 2/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//
//  Swift implementation of the Root Service

import Foundation

@objc final class RootServiceSwift: NSObject {
    @objc public private(set) var isPromptingForBiometricAuthentication = false
    @objc public private(set) var applicationCameFromBackground = false
    fileprivate var loginTimer: Timer?
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

    // MARK: - UIApplicationDelegate methods

    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        self.hidePrivacyScreen()
    }

    @objc func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        if !isPromptingForBiometricAuthentication {
            showPrivacyScreen()
        }
    }

    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        applicationCameFromBackground = true
    }

    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }

    // MARK: - Authentication

    //: Optionally handle preflight error by setting USER_DEFAULTS_KEY_TOUCH_ID_ENABLED
    //: 👆 not implemented b/c biometric authentication is assumed to be preferred by the user (if available)
    @objc func authenticateWithBiometrics() {
        isPromptingForBiometricAuthentication = true
        app.pinEntryViewController.view.isUserInteractionEnabled = false
        AuthenticationManager.shared.authenticateUsingBiometrics { authenticated, authenticationError in
            self.isPromptingForBiometricAuthentication = false
            if let error = authenticationError {
                self.handleBiometricAuthenticationError(withError: error)
            }
            DispatchQueue.main.async {
                app.pinEntryViewController.view.isUserInteractionEnabled = true
            }
            if authenticated {
                DispatchQueue.main.async {
                    self.showVerifyingBusyView(withTime: 30)
                }
                guard
                    // TODO: read pinKey from UserDefaults extension
                    let pinKey = UserDefaults.standard.object(forKey: "pinKey") as? String,
                    let pin = KeychainItemWrapper.pinFromKeychain() else {
                        self.failedToObtainValuesFromKeychain(); return
                }
                app.wallet.apiGetPINValue(pinKey, pin: pin)
            }
        }
    }

    func handleBiometricAuthenticationError(withError error: AuthenticationError) {
        if let description = error.description {
            let alert = UIAlertController(title: LCStringError, message: description, preferredStyle: .alert)
            let action = UIAlertAction(title: LCStringOK, style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                app.window.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Privacy screen

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
    func showVerifyingBusyView(withTime time: Int) {
        app.showBusyView(withLoadingText: LCStringLoadingVerifying)
        // TODO: refactor showVerifyingBusyView with newer iOS 10+ method
        loginTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(time),
            target: self,
            selector: #selector(showErrorLoading),
            userInfo: nil,
            repeats: false
        )
    }
    @objc func showErrorLoading() {
        // TODO: complete showErrorLoading implementation
        if let timer = loginTimer {
            timer.invalidate()
        }
//        if (!self.wallet.guid && busyView.alpha == 1.0 && [busyLabel.text isEqualToString:BC_STRING_LOADING_VERIFYING]) {
//            [self.pinEntryViewController reset];
//            [self hideBusyView];
//            [self standardNotifyAutoDismissingController:BC_STRING_ERROR_LOADING_WALLET];
//        }
    }
}
