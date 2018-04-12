//
//  AuthenticationManager.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LocalAuthentication

/**
 Represents an authentication error.

 Set **description** to `nil` to indicate that the error should be handled silently.
 */
internal struct AuthenticationError {
    let code: Int
    let description: String?
    /**
     - Parameters:
        - code: The error code associated with the object.
        - description: An optional description associated with the object.
     */
    init(code: Int, description: String?) {
        self.code = code
        self.description = description
    }
}

/**
 The authentication manager handles biometric and passcode authentication.
 # Usage
 Call either `biometricAuthentication(withReply:)` or `passcodeAuthentication(withReply:)`
 to request authentication from users through passcodes or biometrics, respectively.
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
*/
@objc
final class AuthenticationManager: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `AuthenticationManager` class.
    static let shared = AuthenticationManager()

    /**
     The type alias for the closure used in:
     * `biometricAuthentication(withReply:)`
     * `passcodeAuthentication(withReply:)`
     */
    typealias Handler = (_ authenticated: Bool, _ error: AuthenticationError?) -> Void

    /**
     The local authentication context.
     - Important: The context **must** be reinitialized each time `biometricAuthentication` is called.
    */
    private var context: LAContext!

    /**
     Used as a fallback for all other errors in:
     * `preFlightError(forBiometryError:)`
     * `preFlightError(forDeprecatedError:)`
     * `authenticationError(forError:)`
    */
    private let genericAuthenticationError: AuthenticationError!

    /// The app-provided reason for requesting authentication, which displays in the authentication dialog presented to the user.
    private lazy var authenticationReason: String = {
        if #available(iOS 11.0, *) {
            if self.context.biometryType == .faceID {
                return LCStringFaceIDAuthenticate
            }
        }
        return LCStringTouchIDAuthenticate
    }()

    /// The error object used prior to policy evaluation.
    var preflightError: NSError?

    // MARK: Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        genericAuthenticationError = AuthenticationError(code: Int.min, description: LCStringAuthGenericError)
    }

    // MARK: - Authentication with Biometrics

    /**
     Authenticates the user using biometrics.
     - Parameter handler: The closure for the authentication reply.
     */
    func biometricAuthentication(withReply handler: @escaping Handler) {
        context = LAContext()
        context.localizedFallbackTitle = LCStringAuthUsePasscode
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = LCStringAuthCancel
        }
        if !canAuthenticateUsingBiometry() {
            handler(false, preFlightError(forError: preflightError!.code)); return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authenticationReason, reply: { authenticated, error in
            if let authError = error {
                handler(false, self.authenticationError(forError: authError)); return
            }
            handler(authenticated, nil)
        })
    }

    /**
     Evaluate whether the device owner can authenticate using biometrics.
     - Returns: A Boolean value that determines whether the policy can be evaluated.
     */
    private func canAuthenticateUsingBiometry() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &preflightError)
    }

    // MARK: - Authentication with Passcode

    /**
     The function used to authenticate the user using a provided passcode.
     - Parameter handler: The completion handler for the authentication reply.
     */
    func passcodeAuthentication(withReply handler: @escaping Handler) {
        // TODO: authenticate user with passcode
    }

    // MARK: - Authentication Errors

    /**
     Preflight errors occur prior to policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func preFlightError(forError code: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            return preFlightError(forBiometryError: code)
        }
        return preFlightError(forDeprecatedError: code)
    }

    /**
     Biometric preflight errors occur prior to policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func preFlightError(forBiometryError code: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            switch code {
            case LAError.biometryLockout.rawValue:
                return AuthenticationError(code: code, description: LCStringAuthBiometryLockout)
            case LAError.biometryNotAvailable.rawValue:
                return AuthenticationError(code: code, description: LCStringAuthBiometryNotAvailable)
            case LAError.biometryNotEnrolled.rawValue:
                return AuthenticationError(code: code, description: nil)
            default:
                return genericAuthenticationError
            }
        }
        return genericAuthenticationError
    }

    /**
     Deprecated preflight errors occur prior to policy evaluation.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func preFlightError(forDeprecatedError code: Int) -> AuthenticationError {
        switch code {
        case LAError.touchIDLockout.rawValue:
            return AuthenticationError(code: code, description: LCStringAuthTouchIDLockout)
        case LAError.touchIDNotAvailable.rawValue:
            return AuthenticationError(code: code, description: LCStringAuthBiometryNotAvailable)
        case LAError.touchIDNotEnrolled.rawValue:
            return AuthenticationError(code: code, description: nil)
        default:
            return genericAuthenticationError
        }
    }

    /**
     Inflight error codes that can be returned when evaluating a policy.
     - Parameter code: The preflight error code.
     - Returns: An object of type `AuthenticationError` associated with the error code.
     - Important: When the description is nil, the error should be handled silently.
     */
    private func authenticationError(forError code: Error) -> AuthenticationError {
        switch code {
        case LAError.authenticationFailed:
            return AuthenticationError(code: LAError.authenticationFailed.rawValue, description: LCStringAuthAuthenticationFailed)
        case LAError.appCancel:
            return AuthenticationError(code: LAError.appCancel.rawValue, description: nil)
        case LAError.passcodeNotSet:
            return AuthenticationError(code: LAError.passcodeNotSet.rawValue, description: LCStringAuthPasscodeNotSet)
        case LAError.systemCancel:
            return AuthenticationError(code: LAError.systemCancel.rawValue, description: nil)
        case LAError.userCancel:
            return AuthenticationError(code: LAError.userCancel.rawValue, description: nil)
        case LAError.userFallback:
            return AuthenticationError(code: LAError.userFallback.rawValue, description: nil)
        default:
            return genericAuthenticationError
        }
    }
}
