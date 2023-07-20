// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import UIKit
import Veriff

protocol VeriffController: UIViewController, VeriffSdkDelegate {

    var veriff: VeriffSdk { get }

    // Actions

    func veriffCredentialsRequest()

    func launchVeriffController(credentials: VeriffCredentials)

    // Completion handlers

    func onVeriffSubmissionCompleted()

    func trackInternalVeriffError(_ error: InternalVeriffError)

    func onVeriffError(message: String)

    func onVeriffCancelled()
}

extension VeriffController {

    internal var veriff: VeriffSdk {
        VeriffSdk.shared
    }

    func launchVeriffController(credentials: VeriffCredentials) {
        veriff.delegate = self
        let configuration = brandingConfiguration()
        veriff.startAuthentication(sessionUrl: credentials.url, configuration: configuration)
    }

    // https://developers.veriff.com/#customize-user-interface-optional
    private func brandingConfiguration() -> VeriffSdk.Configuration {
        let branding = VeriffSdk.Branding()
        branding.logo = UIImage(named: "icon_logo", in: .module, with: nil)
        branding.background = UIColor.semantic.background
        branding.onBackground = UIColor.semantic.title
        branding.onBackgroundSecondary = UIColor.semantic.text
        branding.onBackgroundTertiary = UIColor.semantic.body
        branding.primary = UIColor.semantic.primary
        branding.onPrimary = UIColor.white
        branding.secondary = UIColor.semantic.light
        branding.onSecondary = UIColor.semantic.title
        branding.cameraOverlay = UIColor.semantic.dark
        branding.onCameraOverlay = UIColor.semantic.light
        branding.error = UIColor.semantic.error
        branding.success = UIColor.semantic.success
        branding.outline = UIColor.semantic.border
        branding.secondary = UIColor.semantic.body
        branding.font = .init(
            regular: Typography.FontResource.interRegular.rawValue,
            medium: Typography.FontResource.interMedium.rawValue,
            bold: Typography.FontResource.interBold.rawValue
        )
        branding.buttonRadius = ButtonSize.Standard.cornerRadius
        let configuration = VeriffSdk.Configuration(
            branding: branding,
            languageLocale: .current
        )
        return configuration
    }
}

enum InternalVeriffError: Swift.Error {
    case cameraUnavailable
    case microphoneUnavailable
    case serverError
    case localError
    case networkError
    case uploadError
    case videoFailed
    case deprecatedSDKVersion
    case unknown

    init(veriffError: VeriffSdk.Error) {
        switch veriffError {
        case .cameraUnavailable:
            self = .cameraUnavailable
        case .microphoneUnavailable:
            self = .microphoneUnavailable
        case .serverError:
            self = .serverError
        case .localError:
            self = .localError
        case .networkError:
            self = .networkError
        case .uploadError:
            self = .uploadError
        case .videoFailed:
            self = .videoFailed
        case .deprecatedSDKVersion:
            self = .deprecatedSDKVersion
        case .unknown:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }
}

extension VeriffSdk.Error {
    var localizedErrorMessage: String {
        switch self {
        case .cameraUnavailable:
            return LocalizationConstants.Errors.cameraAccessDeniedMessage
        case .microphoneUnavailable:
            return LocalizationConstants.Errors.microphoneAccessDeniedMessage
        case .deprecatedSDKVersion,
             .localError,
             .networkError,
             .serverError,
             .unknown,
             .uploadError,
             .videoFailed:
            return LocalizationConstants.Errors.genericError
        @unknown default:
            return LocalizationConstants.Errors.genericError
        }
    }
}
