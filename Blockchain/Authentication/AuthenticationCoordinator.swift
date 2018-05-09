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

    var postAuthenticationRoute: PostAuthenticationRoute?

    var lastEnteredPIN: Pin?

    /// Authentication handler - this should not be a property of AuthenticationCoordinator
    /// but the current way wallet creation is designed, we need to share this handler
    /// with that flow. Eventually, wallet creation should be moved with AuthenticationCoordinator
    lazy var authHandler: AuthenticationManager.Handler = { [weak self] isAuthenticated, _, error in
        guard let strongSelf = self else { return }

        LoadingViewPresenter.shared.hideBusyView()

        // Error checking
        guard error == nil, isAuthenticated else {
            switch error!.code {
            case AuthenticationError.ErrorCode.noInternet.rawValue:
                AlertViewPresenter.shared.showNoInternetConnectionAlert()
            case AuthenticationError.ErrorCode.emailAuthorizationRequired.rawValue:
                AlertViewPresenter.shared.showEmailAuthorizationRequired()
            case AuthenticationError.ErrorCode.failedToLoadWallet.rawValue:
                strongSelf.handleFailedToLoadWallet()
            case AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue:
                strongSelf.showPasswordModal()
            default:
                if let description = error!.description {
                    AlertViewPresenter.shared.standardError(message: description)
                }
            }
            return
        }

        ModalPresenter.shared.closeAllModals()

        // Make user set up a pin if none is set. They can also optionally enable touch ID and link their email.
        guard BlockchainSettings.App.shared.isPinSet else {
            if strongSelf.walletManager.wallet.isNew {
                AuthenticationCoordinator.shared.startNewWalletSetUp()
            } else {
                strongSelf.showPinEntryView(asModal: false)
            }
            return
        }

        AppCoordinator.shared.showHdUpgradeViewIfNeeded()

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

        let tabControllerManager = AppCoordinator.shared.tabControllerManager
        tabControllerManager.sendBitcoinViewController?.reload()
        tabControllerManager.sendBitcoinCashViewController?.reload()

        // Enabling touch ID and immediately backgrounding the app hides the status bar
        UIApplication.shared.setStatusBarHidden(false, with: .slide)

        /// Prompt the user for push notification permission
        if #available(iOS 10.0, *) {
            PushNotificationManager.shared.requestAuthorization()
        } else {
            LegacyPushNotificationManager.shared.requestAuthorization()
        }

        // Handle post authentication route, if any
        if let route = strongSelf.postAuthenticationRoute {
            switch route {
            case .sendCoins:
                tabControllerManager.showSendCoins(animated: true)
            }
            strongSelf.postAuthenticationRoute = nil
        }

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

    // MARK: - Start Flows

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
            NetworkManager.shared.checkForMaintenance(withCompletion: { response in
                guard let message = response else { return }
                print("Error checking for maintenance in wallet options: %@", message)
                AlertViewPresenter.shared.standardNotify(message: message, title: LocalizationConstants.Errors.error, handler: nil)
            })
            showPasswordModal()
            AlertViewPresenter.shared.checkAndWarnOnJailbrokenPhones()
        }
        // TODO
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSideMenu)
        // name:NOTIFICATION_KEY_GET_ACCOUNT_INFO_SUCCESS object:nil];
    }

    @objc func startNewWalletSetUp() {
        let setUpWalletViewController = WalletSetupViewController(setupDelegate: self)!
        let topMostViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController
        topMostViewController?.present(setUpWalletViewController, animated: false) { [weak self] in
            self?.showPinEntryView(asModal: false)
        }
    }

    /// Starts the manual wallet pairing flow
    func startManualPairing() {
        let manualPairView = BCManualPairView.instanceFromNib()
        manualPairView.delegate = self
        ModalPresenter.shared.showModal(
            withContent: manualPairView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.Authentication.manualPairing
        )
    }

    /// Unauthenticates the user
    @objc func logout(showPasswordView: Bool) {
        loginTimeout?.invalidate()

        BlockchainSettings.App.shared.clearPin()

        WalletManager.shared.close()

        let appCoordinator = AppCoordinator.shared
        appCoordinator.tabControllerManager.clearSendToAddressAndAmountFields()
        appCoordinator.closeSideMenu()
        appCoordinator.reload()

        if showPasswordView {
            showPasswordModal()
        }
    }

    /// Method to "cleanup" state when the app is backgrounded.
    func cleanupOnAppBackgrounded() {
        guard let pinEntryViewController = pinEntryViewController else { return }
        if !pinEntryViewController.verifyOnly || !pinEntryViewController.inSettings {
            closePinEntryView(animated: false)
        }
    }

    // MARK: - PasswordRequiredViewDelegate Presentation

    @objc func showForgetWalletConfirmAlert() {
        let alert = UIAlertController(
            title: LocalizationConstants.Errors.warning,
            message: LocalizationConstants.Authentication.forgetWalletDetail,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { [unowned self] _ in
                print("Forgetting wallet")
                ModalPresenter.shared.closeModal(withTransition: kCATransitionFade)
                self.walletManager.forgetWallet()
                OnboardingCoordinator.shared.start()
            }
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    /// Starts the wallet pairing flow by scanning a QR code
    func startQRCodePairing() {
        // Check that we have access to the camera
        do {
            _ = try AVCaptureDeviceInput.deviceInputForQRScanner()
        } catch let error as AVCaptureDeviceError {
            switch error.type {
            case .notAuthorized:
                AlertViewPresenter.shared.showNeedsCameraPermissionAlert()
            default:
                AlertViewPresenter.shared.standardError(message: error.localizedDescription)
            }
            return
        } catch {
            AlertViewPresenter.shared.standardError(message: error.localizedDescription)
        }

        let pairingCodeParserViewController = PairingCodeParser(success: { [weak self] response in
            guard let strongSelf = self else { return }
            guard let dictResponse = response else { return }

            let payload = PasscodePayload(dictionary: dictResponse)
            AuthenticationManager.shared.authenticate(using: payload, andReply: strongSelf.authHandler)
        }, error: { error in
            guard let errorMessage = error else { return }
            AlertViewPresenter.shared.standardError(message: errorMessage)
        })!
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            pairingCodeParserViewController,
            animated: true
        )
    }

    private func showForgotPasswordAlert() {
        let title = String(format: LocalizationConstants.openArg, Constants.Url.blockchainSupport)
        let alert = UIAlertController(
            title: title,
            message: LocalizationConstants.youWillBeLeavingTheApp,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
                guard let url = URL(string: Constants.Url.forgotPassword) else { return }
                UIApplication.shared.openURL(url)
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
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

                // Can both of these alerts be moved elsewhere?                                     
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
                    strongSelf.walletManager.wallet.didPairAutomatically = false
                    return
                }
            }
        }
        self.pinEntryViewController = pinViewController

        LoadingViewPresenter.shared.hideBusyView()

        UIApplication.shared.statusBarStyle = .default
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

    /// Displays a view (modal) requesting the user to enter their password.
    ///
    /// - Parameters:
    ///   - displayText: the display/description text in the view presented to the user
    ///   - headertext: the header text to display on the presented modal
    ///   - validateSecondPassword: if the password should be validated against the wallet password
    ///   - handler: completion handler invoked when the user confirms their password
    @objc func showPasswordConfirm(
        withDisplayText displayText: String,
        headerText: String,
        validateSecondPassword: Bool,
        confirmHandler: @escaping PasswordConfirmView.OnPasswordConfirmHandler
    ) {
        let passwordConfirmView = PasswordConfirmView.instanceFromNib()
        passwordConfirmView.validateSecondPassword = validateSecondPassword
        passwordConfirmView.confirmHandler = { [unowned self] password in
            guard password.count > 0 else {
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Authentication.noPasswordEntered)
                return
            }

            guard !passwordConfirmView.validateSecondPassword || self.walletManager.wallet.validateSecondPassword(password) else {
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Authentication.secondPasswordIncorrect)
                return
            }

            confirmHandler(password)
            
            ModalPresenter.shared.closeModal(withTransition: kCATransitionFade)
        }
        ModalPresenter.shared.showModal(
            withContent: passwordConfirmView,
            closeType: ModalCloseTypeClose,
            showHeader: true,
            headerText: headerText
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
        AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.errorLoadingWallet)
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

extension AuthenticationCoordinator: ManualPairViewDelegate {
    func manualPairView(_ manualPairView: BCManualPairView!, didContinueWithGuid guid: String!, andPassword password: String!) {
        let payload = PasscodePayload(guid: guid, password: password, sharedKey: "")
        AuthenticationManager.shared.authenticate(using: payload, andReply: authHandler)

        AuthenticationManager.shared.authenticate(using: payload) { [weak self] isAuthenticated, twoFAtype, error in
            guard let strongSelf = self else { return }
            guard twoFAtype == nil else {
                strongSelf.handle(twoFactorAuthType: twoFAtype!, forManualPairView: manualPairView)
                return
            }
            strongSelf.authHandler(isAuthenticated, twoFAtype, error)
        }
    }

    private func handle(twoFactorAuthType: AuthenticationTwoFactorType, forManualPairView view: BCManualPairView) {
        switch twoFactorAuthType {
        case .google:
            view.verifyTwoFactorGoogle()
        case .yubiKey:
            view.verifyTwoFactorYubiKey()
        case .sms:
            view.verifyTwoFactorSMS()
        default:
            print("Unhandled 2FA type: \(twoFactorAuthType)")
        }
    }
}

extension AuthenticationCoordinator: PasswordRequiredViewDelegate {
    func didTapForgotPassword() {
        showForgotPasswordAlert()
    }

    func didTapForgetWallet() {
        showForgetWalletConfirmAlert()
    }

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
