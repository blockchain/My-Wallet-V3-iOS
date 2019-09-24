//
//  VeriffController.swift
//  Blockchain
//
//  Created by kevinwu on 1/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Veriff

protocol VeriffController: VeriffDelegate {

    var veriff: Veriff { get }

    // Actions

    func veriffCredentialsRequest()

    func launchVeriffController(credentials: VeriffCredentials, version: String)

    // Completion handlers

    func onVeriffSubmissionCompleted()

    func onVeriffError(message: String)

    func onVeriffCancelled()
}

extension VeriffController where Self: UIViewController {
    internal var veriff: Veriff {
        return Veriff.shared
    }

    func launchVeriffController(credentials: VeriffCredentials, version: String) {

        let token = credentials.key
        let value = credentials.url
        guard var url = URL(string: value) else { return }

        /// Other clients have different SDK behaviors and expect that the
        /// `sessionURL` include the `sessionToken` as a parameter. Also
        /// some clients don't need the version number as a parameter. iOS
        /// does, otherwise we get a server error.
        if url.lastPathComponent != version {
            var components = URLComponents(string: value)
            components?.path = version
            guard let modifiedURL = components?.url else { return }
            url = modifiedURL
        }
        let config = VeriffConfiguration(sessionToken: token, sessionUrl: url.absoluteString)

        veriff.set(configuration: config)

        veriff.delegate = self

        veriff.startAuthentication()
    }
}

extension VeriffController {
    func onSession(result: VeriffResult, sessionToken: String) {
        switch result.code {
        case .UNABLE_TO_ACCESS_CAMERA:
            onVeriffError(message: LocalizationConstants.Errors.cameraAccessDeniedMessage)
        case .STATUS_ERROR_SESSION,
             .STATUS_ERROR_NETWORK,
             .STATUS_ERROR_UNKNOWN:
            onVeriffError(message: LocalizationConstants.Errors.genericError)
        case .STATUS_DONE,
             .STATUS_SUBMITTED,
             .STATUS_ERROR_NO_IDENTIFICATION_METHODS_AVAILABLE:
            // DONE: The client got declined while he was still using the SDK
            // - this status can only occur if video_feature is used and FCM token is set.
            // NO_IDENTIFICATION: The session status is finished from clients perspective.
            onVeriffSubmissionCompleted()
        case .STATUS_USER_CANCELED:
            onVeriffCancelled()
            // TODO: Removed since we downgraded `VeriffSDK` from `2.4.0`
            // back to `2.0.5`. Once `VeriffSDK` is upgraded we can get this back in.
//        case .UNABLE_TO_ACCESS_MICROPHONE:
//            onVeriffError(message: LocalizationConstants.Errors.microphoneAccessDeniedMessage)
        }
    }
}
