// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import LocalAuthentication
import Localization
import PlatformKit

public struct Biometry {

    public enum BiometryError: LocalizedError {
        private typealias LocalizedString = LocalizationConstants.Biometry

        case authenticationFailed
        case passcodeNotSet
        case biometryLockout
        case biometryNotAvailable
        case biometryNotEnrolled(type: BiometryType)

        case appCancel
        case systemCancel
        case userCancel
        case userFallback
        case general

        /// A user message corresponding to the error
        public var errorDescription: String? {
            switch self {
            case .authenticationFailed:
                LocalizedString.authenticationFailed
            case .passcodeNotSet:
                LocalizedString.passcodeNotSet
            case .biometryLockout:
                LocalizedString.biometricsLockout
            case .biometryNotAvailable:
                LocalizedString.biometricsNotSupported
            case .biometryNotEnrolled(let type):
                switch type {
                case .faceID:
                    LocalizedString.faceIDEnableInstructions
                case .touchID:
                    LocalizedString.touchIDEnableInstructions
                case .none:
                    LocalizedString.genericError
                }
            case .general:
                LocalizedString.genericError
            case .appCancel,
                 .systemCancel,
                 .userCancel,
                 .userFallback:
                ""
            }
        }

        /// Initializes with error, expects the error to have `code`
        /// compatible code to `LAError.Code.rawValue`
        public init(with error: Error, type: BiometryType) {
            let code = (error as NSError).code
            self.init(with: code, type: type)
        }

        /// Initializes with expected `LAError.Code`'s `rawValue`
        init(with rawCodeValue: Int, type: BiometryType) {
            if let localAuthenticationCode = LAError.Code(rawValue: rawCodeValue) {
                self.init(with: localAuthenticationCode, type: type)
            } else {
                self = .general
            }
        }

        /// Initializes with `LAError.Code` value
        init(with error: LAError.Code, type: BiometryType) {
            switch error {
            case .authenticationFailed:
                self = .authenticationFailed
            case .appCancel:
                self = .appCancel
            case .passcodeNotSet:
                self = .passcodeNotSet
            case .systemCancel:
                self = .systemCancel
            case .userCancel:
                self = .userCancel
            case .userFallback:
                self = .userFallback
            case .touchIDLockout:
                self = .biometryLockout
            case .touchIDNotAvailable:
                self = .biometryNotAvailable
            case .touchIDNotEnrolled:
                self = .biometryNotEnrolled(type: type)
            case .invalidContext,
                 .notInteractive:
                self = .general
            @unknown default:
                self = .general
            }
        }
    }

    // MARK: - Types

    public enum Reason {
        case enterWallet

        var localized: String {
            switch self {
            case .enterWallet:
                LocalizationConstants.Biometry.authenticationReason
            }
        }
    }

    /// Indicates the current biometrics configuration state
    public enum Status {

        /// Not configured on device but there is no restriction for configuring one
        case configurable(BiometryType)

        /// Configured on the device and in app
        case configured(BiometryType)

        /// Cannot be configured because the device do not support it,
        /// or because the user hasn't enabled it, or because that feature is not remotely
        case unconfigurable(Error)

        /// Returns `true` if biometrics is configurable
        public var isConfigurable: Bool {
            switch self {
            case .configurable:
                true
            case .configured, .unconfigurable:
                false
            }
        }

        /// Returns `true` if biometrics is configured
        public var isConfigured: Bool {
            switch self {
            case .configured:
                true
            case .configurable, .unconfigurable:
                false
            }
        }

        /// Returns associated `BiometricsType` if any
        public var biometricsType: BiometryType {
            switch self {
            case .configurable(let type):
                type
            case .configured(let type):
                type
            case .unconfigurable:
                .none
            }
        }
    }

    /// A type of biomety authenticator
    public enum BiometryType {

        /// The device supports Touch ID.
        case touchID

        /// The device supports Face ID.
        case faceID

        /// The device does not support biometry.
        case none

        public init(with systemType: LABiometryType) {
            switch systemType {
            case .faceID:
                self = .faceID
            case .touchID:
                self = .touchID
            case .none:
                self = .none
            @unknown default:
                self = .none
            }
        }

        public var localizedName: String? {
            switch self {
            case .faceID:
                LocalizationConstants.faceId
            case .touchID:
                LocalizationConstants.touchId
            case .none:
                nil
            }
        }

        public var isValid: Bool {
            self != .none
        }
    }

    /// Represents `LAContext` result on calling `canEvaluatePolicy` for biometrics
    public enum EvaluationError: LocalizedError {

        /// Wraps
        case system(BiometryError)
        case notAllowed

        public var errorDescription: String? {
            switch self {
            case .system(let error):
                String(describing: error)
            case .notAllowed:
                LocalizationConstants.Biometry.notConfigured
            }
        }
    }
}
