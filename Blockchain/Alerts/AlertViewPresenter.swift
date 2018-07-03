//
//  AlertViewPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AlertViewPresenter: NSObject {
    typealias AlertConfirmHandler = ((UIAlertAction) -> Void)

    static let shared = AlertViewPresenter()

    @objc class func sharedInstance() -> AlertViewPresenter { return shared }

    private override init() {
        super.init()
    }

    /// Displays an alert that the app requires permission to use the camera. The alert will display an
    /// action which then leads the user to their settings so that they can grant this permission.
    @objc func showNeedsCameraPermissionAlert() {
        let alert = UIAlertController(
            title: LocalizationConstants.Errors.cameraAccessDenied,
            message: LocalizationConstants.Errors.cameraAccessDeniedMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.goToSettings, style: .default) { _ in
                guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.openURL(settingsURL)
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        present(alert: alert)
    }

    /// Asks permission from the user to use values in the keychain. This is typically invoked
    /// on a new installation of the app (meaning the user previously installed the app, deleted it,
    /// and downloaded the app again).
    ///
    /// - Parameter handler: the AlertConfirmHandler invoked when the user **does not** grant permission
    func alertUserAskingToUseOldKeychain(handler: @escaping AlertConfirmHandler) {
        let alert = UIAlertController(
            title: LocalizationConstants.Onboarding.askToUserOldWalletTitle,
            message: LocalizationConstants.Onboarding.askToUserOldWalletMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.Onboarding.createNewWallet, style: .cancel, handler: handler)
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.Onboarding.loginExistingWallet, style: .default)
        )
        present(alert: alert)
    }

    /// Shows the user an alert that the app failed to read values from the keychain.
    /// Upon confirming on the presented alert, the app will terminate.
    @objc func showKeychainReadError() {
        standardNotify(
            message: LocalizationConstants.Errors.errorLoadingWalletIdentifierFromKeychain,
            title: LocalizationConstants.Authentication.failedToLoadWallet
        ) { _ in
            // Close App
            UIApplication.shared.suspendApp()
        }
    }

    @objc func checkAndWarnOnJailbrokenPhones() {
        guard UIDevice.current.isUnsafe() else {
            return
        }
        AlertViewPresenter.shared.standardNotify(
            message: LocalizationConstants.Errors.warning,
            title: LocalizationConstants.Errors.unsafeDeviceWarningMessage
        )
    }

    @objc func showNoInternetConnectionAlert() {
        standardNotify(
            message: LocalizationConstants.Errors.noInternetConnection,
            title: LocalizationConstants.Errors.error
        ) { _ in
            LoadingViewPresenter.shared.hideBusyView()
            // TODO: this should not be in here. Figure out all areas where pin
            // should be reset and explicitly reset pin entry there
            // [self.pinEntryViewController reset];
        }
    }

    @objc func showWaitingForEtherPaymentAlert() {
        standardNotify(
            message: LocalizationConstants.SendEther.waitingForPaymentToFinishMessage,
            title: LocalizationConstants.SendEther.waitingForPaymentToFinishTitle)
    }

    /// Displays the standard error alert
    @objc func standardError(
        message: String,
        title: String = LocalizationConstants.Errors.error,
        in viewController: UIViewController? = nil,
        handler: AlertConfirmHandler? = nil
    ) {
        standardNotify(message: message, title: title, in: viewController, handler: handler)
    }

    @objc func standardNotify(
        message: String,
        title: String,
        in viewController: UIViewController? = nil,
        handler: AlertConfirmHandler? = nil
    ) {
        let standardAction = UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: handler)
        standardNotify(message: message, title: title, actions: [standardAction], in: viewController)
    }

    /// Allows custom actions to be included in the standard alert presentation
    @objc func standardNotify(
        message: String,
        title: String,
        actions: [UIAlertAction],
        in viewController: UIViewController? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        if actions.isEmpty {
            alert.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
        }
        standardNotify(alert: alert, in: viewController)
    }

    private func standardNotify(alert: UIAlertController, in viewController: UIViewController? = nil) {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow
            let rootController = window?.rootViewController
            let presentingViewController = viewController ?? rootController?.topMostViewController ?? rootController
            presentingViewController?.present(alert, animated: true)
        }
    }

    private func present(alert: UIAlertController) {
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }
}
