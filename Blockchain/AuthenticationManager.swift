//
//  AuthenticationManager.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LocalAuthentication

internal struct AuthenticationError {
    let code: Int!
    let description: String?
}

@objc final class AuthenticationManager: NSObject {
    static let shared = AuthenticationManager()

    typealias Handler = (_ authenticated: Bool, _ error: AuthenticationError?) -> Void

    private var context: LAContext = LAContext()
    private let genericAuthenticationError: AuthenticationError!
    private lazy var authenticationReason: String = {
        if #available(iOS 11.0, *) {
            if self.context.biometryType == .faceID {
                return LCStringFaceIDAuthenticate
            }
        }
        return LCStringTouchIDAuthenticate
    }()
    var preflightError: NSError?

    // MARK: - Initialization

    override init() {
        context.localizedFallbackTitle = LCStringAuthUsePasscode
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = LCStringAuthCancel
        }
        genericAuthenticationError = AuthenticationError(code: Int.min, description: LCStringAuthGenericError)
    }

    // MARK: - Authentication with Biometrics

    func biometricAuthentication(withReply handler: @escaping Handler) {
        context = LAContext()
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
    //: Evaluate whether the device owner can authenticate with biometrics
    private func canAuthenticateUsingBiometry() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &preflightError)
    }

    //: MARK: - Authentication with Passcode

    func passcodeAuthentication(withReply handler: @escaping Handler) {
        // TODO: authenticate user with passcode...
    }

    // MARK: - Authentication Errors

    //: Preflight errors occur prior to policy evaluation
    private func preFlightError(forError code: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            return preFlightError(forBiometryError: code)
        }
        return preFlightError(forDeprecatedError: code)
    }
    //: Biometric preflight errors
    private func preFlightError(forBiometryError code: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            switch code {
            case LAError.biometryLockout.rawValue:
                return AuthenticationError(code: code, description: LCStringAuthBiometryLockout)
            case LAError.biometryNotAvailable.rawValue:
                return AuthenticationError(code: code, description: LCStringAuthBiometryNotAvailable)
            case LAError.biometryNotEnrolled.rawValue:
                return AuthenticationError(code: code, description: LCStringAuthBiometryNotEnrolled)
            default:
                return genericAuthenticationError
            }
        }
        return genericAuthenticationError
    }
    //: Deprecated preflight errors
    private func preFlightError(forDeprecatedError code: Int) -> AuthenticationError {
        switch code {
        case LAError.touchIDLockout.rawValue:
            return AuthenticationError(code: code, description: LCStringAuthTouchIDLockout)
        case LAError.touchIDNotAvailable.rawValue:
            return AuthenticationError(code: code, description: LCStringAuthBiometryNotAvailable)
        case LAError.touchIDNotEnrolled.rawValue:
            return AuthenticationError(code: code, description: LCStringAuthTouchIDNotEnrolled)
        default:
            return genericAuthenticationError
        }
    }
    //: Inflight error codes that can be returned when evaluating a policy
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
