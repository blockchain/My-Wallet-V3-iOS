// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import DIKit
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public protocol MicrophonePrompting: AnyObject {
    var permissionsRequestor: PermissionsRequestor { get set }
    var microphonePromptingDelegate: MicrophonePromptingDelegate? { get set }

    func checkMicrophonePermissions()
    func willUseMicrophone()
}

extension MicrophonePrompting {
    public func checkMicrophonePermissions() {
        permissionsRequestor.requestPermissions([.microphone]) { [weak self] in
            guard let self else { return }
            microphonePromptingDelegate?.onMicrophonePromptingComplete()
        }
    }

    public func willUseMicrophone() {
        guard PermissionsRequestor.shouldDisplayMicrophonePermissionsRequest() else {
            microphonePromptingDelegate?.onMicrophonePromptingComplete()
            return
        }
        microphonePromptingDelegate?.promptToAcceptMicrophonePermissions(confirmHandler: checkMicrophonePermissions)
    }
}

public protocol MicrophonePromptingDelegate: AnyObject {
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }

    func onMicrophonePromptingComplete()
    func promptToAcceptMicrophonePermissions(confirmHandler: @escaping (() -> Void))
}

extension MicrophonePromptingDelegate {

    public func promptToAcceptMicrophonePermissions(
        confirmHandler: @escaping (() -> Void)
    ) {
        promptToAcceptMicrophonePermissionsAlert(confirmHandler: confirmHandler)
    }

    func promptToAcceptMicrophonePermissionsAlert(
        topViewController: TopMostViewControllerProviding = DIKit.resolve(),
        confirmHandler: @escaping (() -> Void)
    ) {

        guard let topController = topViewController.topMostViewController else {
            return
        }

        let alert = Alert(
            title: LocalizationConstants.KYC.allowMicrophoneAccess,
            message: LocalizationConstants.KYC.enableMicrophoneDescription,
            buttons: [
                Alert.Button(
                    title: LocalizationConstants.okString,
                    style: .primary,
                    action: { [weak self] in
                        topController.dismissAlert()
                        self?.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreMicApprove)
                        confirmHandler()
                    }
                ),
                Alert.Button(
                    title: LocalizationConstants.KYC.notNow,
                    style: .standard,
                    action: {
                        topController.dismissAlert()
                        self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreMicDecline)
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
