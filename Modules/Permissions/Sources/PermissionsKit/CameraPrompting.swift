// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import DIKit
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public protocol CameraPrompting: AnyObject {
    var permissionsRequestor: PermissionsRequestor { get set }
    var cameraPromptingDelegate: CameraPromptingDelegate? { get set }

    // Call this when an action requires camera usage
    func willUseCamera()

    func requestCameraPermissions()
}

extension CameraPrompting where Self: MicrophonePrompting {
    public func willUseCamera() {
        guard PermissionsRequestor.cameraRefused() == false else {
            cameraPromptingDelegate?.showCameraPermissionsDenied()
            return
        }

        guard PermissionsRequestor.shouldDisplayCameraPermissionsRequest() else {
            willUseMicrophone()
            return
        }

        cameraPromptingDelegate?.promptToAcceptCameraPermissions(confirmHandler: {
            self.requestCameraPermissions()
        })
    }

    public func requestCameraPermissions() {
        permissionsRequestor.requestPermissions([.camera]) { [weak self] in
            guard let this = self else { return }
            switch PermissionsRequestor.cameraEnabled() {
            case true:
                // delay needed for better animation for navigation between alerts
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    this.willUseMicrophone()
                }
            case false:
                this.cameraPromptingDelegate?.showCameraPermissionsDenied()
            }
        }
    }
}

public protocol CameraPromptingDelegate: AnyObject {
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }

    func showCameraPermissionsDenied()
    func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void))
}

extension CameraPromptingDelegate {

    public func showCameraPermissionsDenied() {
        showCameraPermissionsDeniedAlert()
    }

    func showCameraPermissionsDeniedAlert(
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {

        guard let topController = topViewController.topMostViewController else {
            return
        }

        let alert = Alert(
            title: LocalizationConstants.Errors.cameraAccessDenied,
            message: LocalizationConstants.Errors.cameraAccessDeniedMessage,
            buttons: [
                Alert.Button(
                    title: LocalizationConstants.goToSettings,
                    style: .primary,
                    action: {
                        topController.dismissAlert()
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                    }
                ),
                Alert.Button(
                    title: LocalizationConstants.KYC.notNow,
                    style: .standard,
                    action: {
                        topController.dismissAlert()
                    }
                )
            ],
            close: {
                topController.dismissAlert()
            }
        )
        topController.presentAlert(UIHostingController(rootView: alert))
    }

    public func promptToAcceptCameraPermissions(
        confirmHandler: @escaping (() -> Void)
    ) {
        promptToAcceptCameraPermissionsAlert(confirmHandler: confirmHandler)
    }

    func promptToAcceptCameraPermissionsAlert(
        topViewController: TopMostViewControllerProviding = DIKit.resolve(),
        confirmHandler: @escaping (() -> Void)
    ) {

        guard let topController = topViewController.topMostViewController else {
            return
        }

        let alert = Alert(
            title: LocalizationConstants.KYC.allowCameraAccess,
            message: LocalizationConstants.KYC.enableCameraDescription,
            buttons: [
                Alert.Button(
                    title: LocalizationConstants.okString,
                    style: .primary,
                    action: { [weak self] in
                        topController.dismissAlert()
                        self?.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreCameraApprove)
                        confirmHandler()
                    }
                ),
                Alert.Button(
                    title: LocalizationConstants.KYC.notNow,
                    style: .standard,
                    action: { [weak self] in
                        topController.dismissAlert()
                        self?.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreCameraDecline)
                    }
                )
            ],
            close: {
                topController.dismissAlert()
            }
        )

        topController.presentAlert(UIHostingController(rootView: alert))
    }
}
