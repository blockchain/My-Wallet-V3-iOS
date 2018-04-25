//
//  AuthenticationCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AuthenticationCoordinator: NSObject, Coordinator {

    @objc static let shared = AuthenticationCoordinator()

    var lastEnteredPIN: Pin?

    private(set) var pinEntryViewController: PEPinEntryController?

    // TODO: loginTimout is never invalidated after a successful login
    private var loginTimeout: Timer?

    private var pinViewControllerCallback: ((Bool) -> Void)?

    private var isPinEntryModalPresented: Bool {
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let tabControllerManager = AppCoordinator.shared.tabControllerManager
        return !(pinEntryViewController == nil ||
            pinEntryViewController!.isBeingDismissed ||
            !pinEntryViewController!.view.isDescendant(of: rootViewController.view) ||
            tabControllerManager.tabViewController.presentedViewController != pinEntryViewController)
    }

    // MARK: - Public

    @objc func start() {
        if WalletManager.shared.wallet.isNew {
            startNewWalletSetUp()
        } else {
            showPinEntryView(asModal: false)
        }
    }

    @objc func startNewWalletSetUp() {
        let setUpWalletViewController = WalletSetupViewController(setupDelegate: self)!
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController
        topMostViewController?.present(setUpWalletViewController, animated: false) { [weak self] in
            self?.showPinEntryView(asModal: false)
        }
    }

    // Closes the pin entry modal, if presented
    @objc func closePinEntryView(animated: Bool) {
        guard let pinEntryViewController = pinEntryViewController else {
             return
        }

        // There are two different ways the pinModal is displayed: as a subview of tabViewController (on start)
        // and as a viewController. This checks which one it is and dismisses accordingly
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        if pinEntryViewController.view.isDescendant(of: rootViewController.view) {
            pinEntryViewController.view.removeFromSuperview()
        } else {
            pinEntryViewController.dismiss(animated: true)
        }

        self.pinEntryViewController = nil

        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }

    @objc func showPinEntryView(asModal: Bool) {

        guard !WalletManager.shared.didChangePassword else {
            showPasswordModal()
            return
        }

        // Don't show pin entry if it is already in view hierarchy
        guard !isPinEntryModalPresented else {
            return
        }

        // Backgrounding from resetting PIN screen hides the status bar
        UIApplication.shared.setStatusBarHidden(false, with: .none)

        let pinViewController: PEPinEntryController
        if BlockchainSettings.App.shared.isPinSet {
            // if pin exists - verify
            pinViewController = PEPinEntryController.pinVerify()
        } else {
            // no pin - create
            pinViewController = PEPinEntryController.pinCreate()
        }
        pinViewController.isNavigationBarHidden = true
        pinViewController.pinDelegate = self

        // asView inserts the modal's view into the rootViewController as a view -
        // this is only used in didFinishLaunching so there is no delay when showing the PIN on start
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        if asModal {

            // TODO handle settings navigation controller
//            if ([_settingsNavigationController isBeingPresented]) {
//                // Immediately after enabling touch ID, backgrounding the app while the Settings scren is still
            // being presented results in failure to add the PIN screen back. Using a delay to allow animation to complete fixes this
//                [[UIApplication sharedApplication].keyWindow.rootViewController.view
            // performSelector:@selector(addSubview:) withObject:self.pinEntryViewController.view afterDelay:DELAY_KEYBOARD_DISMISSAL];
//                [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
//            } else {
            rootViewController.view.addSubview(pinViewController.view)
//            }
        } else {
            let topMostViewController = rootViewController.topMostViewController
            topMostViewController?.present(pinViewController, animated: true) { [weak self] in
                guard self != nil else { return }

                if WalletManager.shared.wallet.isNew {
                    AlertViewPresenter.shared.standardNotify(
                        message: LocalizationConstants.Authentication.didCreateNewWalletMessage,
                        title: LocalizationConstants.Authentication.didCreateNewWalletTitle
                    )
                    return
                }

                if WalletManager.shared.wallet.didPairAutomatically {
                    AlertViewPresenter.shared.standardNotify(
                        message: LocalizationConstants.Authentication.walletPairedSuccessfullyMessage,
                        title: LocalizationConstants.Authentication.walletPairedSuccessfullyTitle
                    )
                    return
                }
            }
        }
        self.pinEntryViewController = pinViewController

        WalletManager.shared.wallet.didPairAutomatically = false

        LoadingViewPresenter.shared.hideBusyView()

        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }

    // MARK: - Private

    private func showPasswordModal() {
        // TODO migrate this from RootService
    }

    private func showVerifyingBusyView(withTimeout seconds: Int) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.verifying)

        // TODO: this timeout approach should be deprecated in favor of checking actual success/error responses
        if #available(iOS 10.0, *) {
            loginTimeout = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
                self?.showLoginError()
            }
        } else {
            loginTimeout = Timer.scheduledTimer(
                timeInterval: TimeInterval(seconds),
                target: self,
                selector: #selector(showLoginError),
                userInfo: nil,
                repeats: false
            )
        }
    }

    @objc private func showLoginError() {
        loginTimeout?.invalidate()
        loginTimeout = nil

        guard WalletManager.shared.wallet.guid == nil else {
            return
        }
        pinEntryViewController?.reset()
        LoadingViewPresenter.shared.hideBusyView()
        AlertViewPresenter.shared.standardNotify(message: LocalizationConstants.Errors.errorLoadingWallet)
    }
}

extension AuthenticationCoordinator: PEPinEntryControllerDelegate {
    func pinEntryController(
        _ pinEntryController: PEPinEntryController!,
        shouldAcceptPin pinInt: UInt,
        callback: ((Bool) -> Void)!
    ) {
        let pin = Pin(code: pinInt)
        self.lastEnteredPIN = pin

        // Check if we have an internet connection
        // This only checks if a network interface is up. All other errors (including timeouts)
        // are handled by JavaScript callbacks in Wallet.m
        guard Reachability.hasInternetConnection() else {
            AlertViewPresenter.shared.showNoInternetConnectionAlert()
            return
        }

        showVerifyingBusyView(withTimeout: 30)


        let pinKey = BlockchainSettings.App.shared.pinKey
        let pinString = pin.toString

        // TODO: Handle touch ID
//        #ifdef ENABLE_TOUCH_ID
//        if (self.pinEntryViewController.verifyOptional) {
//            [KeychainItemWrapper setPINInKeychain:pin];
//        }
//        #endif

        // TODO: migrate check for maintenance

//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self checkForMaintenanceWithPinKey:pinKey pin:pin];
//        });

        self.pinViewControllerCallback = callback
    }

    func pinEntryController(_ pinEntryController: PEPinEntryController!, changedPin pinInt: UInt) {
        let pin = Pin(code: pinInt)
        self.lastEnteredPIN = pin

        guard WalletManager.shared.wallet.isInitialized() || WalletManager.shared.wallet.password != nil else {
            // TODO: migrate pin errors
            // [self didFailPutPin:BC_STRING_CANNOT_SAVE_PIN_CODE_WHILE];
            return
        }

        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.verifying)

        try? pin.save()
    }

    func pinEntryController(_ pinEntryController: PEPinEntryController!, willChangeToNewPin pinInt: UInt) {
        let pin = Pin(code: pinInt)

        // Check that the selected pin passes checks

        guard pin.isValid else {
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.Authentication.chooseAnotherPin,
                title: LocalizationConstants.Errors.error
            ) { [unowned self] _ in
                self.reopenChangePin()
            }
            return
        }

        guard pin != self.lastEnteredPIN else {
            AlertViewPresenter.shared.standardNotify(
                message: LocalizationConstants.Authentication.newPinMustBeDifferent,
                title: LocalizationConstants.Errors.error
            ) { [unowned self] _ in
                self.reopenChangePin()
            }
            return
        }

        guard !pin.isCommon else {
            let alert = UIAlertController(
                title: LocalizationConstants.Errors.warning,
                message: LocalizationConstants.Authentication.pinCodeCommonMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: LocalizationConstants.continueString, style: .default))
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.tryAgain, style: .cancel) {  [unowned self] _ in
                    self.reopenChangePin()
                }
            )
            pinEntryController.present(alert, animated: true)
            return
        }
    }

    func pinEntryControllerDidCancel(_ pinEntryController: PEPinEntryController!) {
        print("Pin change cancelled!")
        closePinEntryView(animated: true)
    }

    private func reopenChangePin() {
        closePinEntryView(animated: false)

        guard let pinViewController = PEPinEntryController.pinCreate() else {
            return
        }

        pinViewController.isNavigationBarHidden = true
        pinViewController.pinDelegate = self

        if BlockchainSettings.App.shared.isPinSet {
            pinViewController.inSettings = true
        }

        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(pinViewController.view)

        pinEntryViewController = pinViewController
    }
}

extension AuthenticationCoordinator: SetupDelegate {
    func enableTouchIDClicked() -> Bool {
        // TODO: handle touch ID
        return false
    }
}
