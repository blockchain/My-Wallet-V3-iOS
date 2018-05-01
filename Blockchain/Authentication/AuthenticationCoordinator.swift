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

    @objc class func sharedInstance() -> AuthenticationCoordinator {
        return shared
    }

    var lastEnteredPIN: Pin?

    /// Authentication handler - this should not be a property of AuthenticationCoordinator
    /// but the current way wallet creation is designed, we need to share this handler
    /// with that flow. Eventually, wallet creation should be moved with AuthenticationCoordinator
    lazy var authHandler: AuthenticationManager.Handler = { [weak self] isAuthenticated, error in
        guard let strongSelf = self else { return }

        LoadingViewPresenter.shared.hideBusyView()

        // Error checking
        guard error == nil, isAuthenticated else {
            switch error!.code {
            case AuthenticationError.ErrorCode.noInternet.rawValue:
                AlertViewPresenter.shared.showNoInternetConnectionAlert()
            case AuthenticationError.ErrorCode.failedToLoadWallet.rawValue:
                strongSelf.handleFailedToLoadWallet()
            default:
                if let description = error!.description {
                    AlertViewPresenter.shared.standardNotify(message: description)
                }
            }
            return
        }

        ModalPresenter.shared.closeAllModals()

        if BlockchainSettings.App.shared.isPinSet {
            AppCoordinator.shared.showHdUpgradeViewIfNeeded()
        }

        // New wallet set-up. This will guide the user to create a pin & optionally
        // enable touch ID and email
        guard !strongSelf.walletManager.wallet.isNew else {
            AuthenticationCoordinator.shared.startNewWalletSetUp()
            return
        }

        // Show security reminder modal if needed
        if let dateOfLastSecurityReminder = BlockchainSettings.App.shared.reminderModalDate {

            // TODO: hook up debug settings to show security reminder
            let timeIntervalBetweenPrompts = Constants.Time.securityReminderModalTimeInterval

            if dateOfLastSecurityReminder.timeIntervalSinceNow < -timeIntervalBetweenPrompts {
                ReminderCoordinator.shared.showSecurityReminder()
            }
        } else if BlockchainSettings.App.shared.hasSeenEmailReminder {
            ReminderCoordinator.shared.showSecurityReminder()
        } else {
            ReminderCoordinator.shared.checkIfSettingsLoadedAndShowEmailReminder()
        }

        // TODO
//        let tabControllerManager = AppCoordinator.shared.tabControllerManager
//        tabControllerManager.sendBitcoinViewController.reload()
//        tabControllerManager.sendBitcoinCashViewController.reload()

        // Enabling touch ID and immediately backgrounding the app hides the status bar
        UIApplication.shared.setStatusBarHidden(false, with: .slide)

        LegacyPushNotificationManager.shared.registerDeviceForPushNotifications()

        // TODO
        // if (showType == ShowTypeSendCoins) {
        //     [self showSendCoins];
        // } else if (showType == ShowTypeNewPayment) {
        //     [self.tabControllerManager showTransactionsAnimated:YES];
        // }
        // showType = ShowTypeNone;

        if let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController,
            BlockchainSettings.App.shared.isPinSet,
            !(topViewController is SettingsNavigationController) {
            AlertViewPresenter.shared.showMobileNoticeIfNeeded()
        }
    }

    internal let walletManager: WalletManager

    internal(set) var pinEntryViewController: PEPinEntryController?

    // TODO: loginTimout is never invalidated after a successful login
    internal var loginTimeout: Timer?

    internal var pinViewControllerCallback: ((Bool) -> Void)?

    private var isPinEntryModalPresented: Bool {
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        let tabControllerManager = AppCoordinator.shared.tabControllerManager
        return !(pinEntryViewController == nil ||
            pinEntryViewController!.isBeingDismissed ||
            !pinEntryViewController!.view.isDescendant(of: rootViewController.view) ||
            tabControllerManager.tabViewController.presentedViewController != pinEntryViewController)
    }

    /// Flag used to indicate whether the device is prompting for biometric authentication.
    @objc internal(set) var isPromptingForBiometricAuthentication = false

    // MARK: - Initializer

    init(walletManager: WalletManager = WalletManager.shared) {
        self.walletManager = walletManager
        super.init()
        self.walletManager.pinEntryDelegate = self
    }

    // MARK: - Public

    /// Starts the authentication flow. If the user has a pin set, it will trigger
    /// present the pin entry screen, otherwise, it will show the password screen.
    @objc func start() {
        guard !walletManager.wallet.isNew else {
            startNewWalletSetUp()
            return
        }

        BlockchainSettings.App.shared.hasSeenAllCards = true
        BlockchainSettings.App.shared.shouldHideAllCards = true

        if BlockchainSettings.App.shared.isPinSet {
            showPinEntryView(asModal: true)
            // TODO enable touch ID
//            #ifdef ENABLE_TOUCH_ID
//            if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_TOUCH_ID_ENABLED]) {
//                [self authenticateWithTouchID];
//            }
//            #endif
            authenticateWithBiometrics()
        } else {
            checkForMaintenance()
            showPasswordModal()
            AlertViewPresenter.shared.checkAndWarnOnJailbrokenPhones()
        }

        // TODO
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSideMenu)
        // name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
        //
        // [self migratePasswordAndPinFromNSUserDefaults];
    }

    /// Unauthenticates the user
    @objc func logout() {
        // TODO
        //        [self.loginTimer invalidate];
        //
        //        [WalletManager.sharedInstance.wallet resetSyncStatus];
        //
        //        [WalletManager.sharedInstance.wallet loadBlankWallet];
        //
        //        WalletManager.sharedInstance.wallet.hasLoadedAccountInfo = NO;
        //
        //        WalletManager.sharedInstance.latestMultiAddressResponse = nil;
        //
        //        [self.tabControllerManager logout];
        //
        //        _settingsNavigationController = nil;
        //
        //        [AppCoordinator.sharedInstance reload];
        //
        //        [WalletManager.sharedInstance.wallet.ethSocket closeWithCode:WEBSOCKET_CODE_LOGGED_OUT reason:WEBSOCKET_CLOSE_REASON_LOGGED_OUT];
        //        [WalletManager.sharedInstance.wallet.btcSocket closeWithCode:WEBSOCKET_CODE_LOGGED_OUT reason:WEBSOCKET_CLOSE_REASON_LOGGED_OUT];
        //        [WalletManager.sharedInstance.wallet.bchSocket closeWithCode:WEBSOCKET_CODE_LOGGED_OUT reason:WEBSOCKET_CLOSE_REASON_LOGGED_OUT];
    }

    @objc func startNewWalletSetUp() {
        let setUpWalletViewController = WalletSetupViewController(setupDelegate: self)!
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController
        topMostViewController?.present(setUpWalletViewController, animated: false) { [weak self] in
            self?.showPinEntryView(asModal: false)
        }
    }

    func checkForMaintenance(withPinKey pinKey: String? = nil, pin: String? = nil) {
        // TODO
        //    NSURL *url = [NSURL URLWithString:[[[BlockchainAPI sharedInstance] walletUrl] stringByAppendingString:URL_SUFFIX_WALLET_OPTIONS]];
        //    // session.sessionDescription = url.host;
        //    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        //    NSURLSessionDataTask *task = [[[NetworkManager sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            if (error) {
        //                DLog(@"Error checking for maintenance in wallet options: %@", [error localizedDescription]);
        //                [self hideBusyView];
        //                [self.pinEntryViewController reset];
        //                [self showMaintenanceAlertWithTitle:BC_STRING_ERROR message:BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION];
        //            }
        //            NSError *jsonError;
        //            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        //            if (jsonError) {
        //                DLog(@"Error parsing response from checking for maintenance in wallet options: %@", [error localizedDescription]);
        //                [self hideBusyView];
        //                [self.pinEntryViewController reset];
        //                [self showMaintenanceAlertWithTitle:BC_STRING_ERROR message:BC_STRING_REQUEST_FAILED_PLEASE_CHECK_INTERNET_CONNECTION];
        //            } else {
        //                if ([[result objectForKey:DICTIONARY_KEY_MAINTENANCE] boolValue]) {
        //                    NSDictionary *mobileInfo = [result objectForKey:DICTIONARY_KEY_MOBILE_INFO];
        //                    NSString *message = [mobileInfo objectForKey:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]] ? : [mobileInfo objectForKey:@"en"];
        //                    [self hideBusyView];
        //                    [self.pinEntryViewController reset];
        //                    [self showMaintenanceAlertWithTitle:BC_STRING_INFORMATION message:message];
        //                } else {
        //                    if (pinKey && pin) {
        //                        [WalletManager.sharedInstance.wallet apiGetPINValue:pinKey pin:pin];
        //                    }
        //                }
        //            }
        //        });
        //    }];
        //    [task resume];
    }

    // MARK: - Pin Entry Presentation

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

        guard !walletManager.didChangePassword else {
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
                guard let strongSelf = self else { return }

                if strongSelf.walletManager.wallet.isNew {
                    AlertViewPresenter.shared.standardNotify(
                        message: LocalizationConstants.Authentication.didCreateNewWalletMessage,
                        title: LocalizationConstants.Authentication.didCreateNewWalletTitle
                    )
                    return
                }

                if strongSelf.walletManager.wallet.didPairAutomatically {
                    AlertViewPresenter.shared.standardNotify(
                        message: LocalizationConstants.Authentication.walletPairedSuccessfullyMessage,
                        title: LocalizationConstants.Authentication.walletPairedSuccessfullyTitle
                    )
                    return
                }
            }
        }
        self.pinEntryViewController = pinViewController

        walletManager.wallet.didPairAutomatically = false

        LoadingViewPresenter.shared.hideBusyView()

        UIApplication.shared.setStatusBarStyle(.default, animated: false)
    }

    // MARK: - Password Presentation

    // TODO: make private once migrated
    @objc func showPasswordModal() {
        let passwordRequestedView = PasswordRequiredView.instanceFromNib()
        passwordRequestedView.delegate = self
        ModalPresenter.shared.showModal(
            withContent: passwordRequestedView,
            closeType: ModalCloseTypeNone,
            showHeader: true,
            headerText: LocalizationConstants.Authentication.passwordRequired
        )
    }

    // MARK: - Internal

    @objc internal func showLoginError() {
        loginTimeout?.invalidate()
        loginTimeout = nil

        guard walletManager.wallet.guid == nil else {
            return
        }
        pinEntryViewController?.reset()
        LoadingViewPresenter.shared.hideBusyView()
        AlertViewPresenter.shared.standardNotify(message: LocalizationConstants.Errors.errorLoadingWallet)
    }

    // MARK: - Private

    private func handleFailedToLoadWallet() {
        guard let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else {
            return
        }

        let alertController = UIAlertController(
            title: LocalizationConstants.Authentication.failedToLoadWallet,
            message: LocalizationConstants.Authentication.failedToLoadWalletDetail,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { _ in

                let forgetWalletAlert = UIAlertController(
                    title: LocalizationConstants.Errors.warning,
                    message: LocalizationConstants.Authentication.forgetWalletDetail,
                    preferredStyle: .alert
                )
                forgetWalletAlert.addAction(
                    UIAlertAction(title: LocalizationConstants.cancel, style: .cancel) { [unowned self] _ in
                        self.handleFailedToLoadWallet()
                    }
                )
                forgetWalletAlert.addAction(
                    UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { [unowned self] _ in
                        self.walletManager.forgetWallet()
                        OnboardingCoordinator.shared.start()
                    }
                )
                topMostViewController.present(forgetWalletAlert, animated: true)
            }
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { _ in
                UIApplication.shared.suspend()
            }
        )
        topMostViewController.present(alertController, animated: true)
    }
}

extension AuthenticationCoordinator: PasswordRequiredViewDelegate {
    func didContinue(with password: String) {

        // Guard checks before attempting to authenticate
        guard let guid = BlockchainSettings.App.shared.guid,
            let sharedKey = BlockchainSettings.App.shared.sharedKey else {
            AlertViewPresenter.shared.showKeychainReadError()
            return
        }

        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.Authentication.downloadingWallet)

        let payload = PasscodePayload(guid: guid, password: password, sharedKey: sharedKey)
        AuthenticationManager.shared.authenticate(using: payload, andReply: authHandler)
    }
}

extension AuthenticationCoordinator: SetupDelegate {
    func enableTouchIDClicked() -> Bool {
        // TODO: handle touch ID
        return false
    }
}
