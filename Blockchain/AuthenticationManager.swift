//
//  AuthenticationManager.swift
//  Blockchain
//
//  Created by Maurice A. on 2/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LocalAuthentication

@objc final class AuthenticationManager : NSObject {
    static let shared = AuthenticationManager()
    
    struct AuthenticationError {
        let code: Int
        let message: String
    }
    
    typealias handler = (_ authenticated: Bool, _ error: AuthenticationError?) -> Void
    
    private let context: LAContext
    private let genericAuthenticationError: AuthenticationError!
    private lazy var authenticationReason: String = {
        if #available(iOS 11.0, *) {
            if self.context.biometryType == .faceID {
                return BC_STRING_FACE_ID_AUTHENTICATE
            }
        }
        return BC_STRING_TOUCH_ID_AUTHENTICATE
    }()
    var preFlightError: NSError?
    
    override init() {
        context = LAContext()
        context.localizedFallbackTitle = BC_STRING_AUTH_USE_PASSCODE
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = BC_STRING_AUTH_CANCEL
        }
        genericAuthenticationError = AuthenticationError(code: Int.min, message: BC_STRING_AUTH_GENERIC_ERROR)
        preFlightError = nil
    }
    
    // MARK: - Authentication with Biometrics
    
    func biometricAuthentication(with reply: @escaping handler) {
        if !canAuthenticateUsingBiometry() {
            reply(false, preFlightError(for: preFlightError!.code)); return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authenticationReason, reply: { authenticated, error in
            if let authError = error {
                reply(false, self.authenticationError(for: authError)); return
            }
            reply(authenticated, nil)
        })
    }
    
    private func canAuthenticateUsingBiometry() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &preFlightError)
    }
    
    //: MARK: - Authentication with Passcode
    
    func passcodeAuthentication(with reply: @escaping handler) {
        // TODO: authenticate user with passcode...
    }
    
    // MARK: - Authentication Errors
    
    //: Preflight errors occur prior to policy evaluation
    private func preFlightError(for errorCode: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            return preFlightError(forBiometry: errorCode)
        }
        return preFlightError(forDeprecated: errorCode)
    }
    
    private func preFlightError(forBiometry errorCode: Int) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            switch errorCode {
            case LAError.biometryLockout.rawValue:
                return AuthenticationError(code: errorCode, message: BC_STRING_AUTH_BIOMETRY_LOCKOUT)
            case LAError.biometryNotAvailable.rawValue:
                return AuthenticationError(code: errorCode, message: BC_STRING_AUTH_BIOMETRY_NOT_AVAILABLE)
            case LAError.biometryNotEnrolled.rawValue:
                return AuthenticationError(code: errorCode, message: BC_STRING_AUTH_BIOMETRY_NOT_ENROLLED)
            default:
                return genericAuthenticationError
            }
        }
        return genericAuthenticationError
    }
    
    private func preFlightError(forDeprecated errorCode: Int) -> AuthenticationError {
        switch errorCode {
        case LAError.touchIDLockout.rawValue:
            return AuthenticationError(code: errorCode, message: BC_STRING_AUTH_TOUCH_ID_LOCKOUT)
        case LAError.touchIDNotAvailable.rawValue:
            return AuthenticationError(code: errorCode, message: BC_STRING_AUTH_TOUCH_ID_NOT_AVAILABLE)
        case LAError.touchIDNotEnrolled.rawValue:
            return AuthenticationError(code: errorCode, message: BC_STRING_AUTH_TOUCH_ID_NOT_ENROLLED)
        default:
            return genericAuthenticationError
        }
    }
    
    //: Inflight errors occur during policy evaluation
    private func authenticationError(for error: Error) -> AuthenticationError {
        switch error {
        case LAError.authenticationFailed:
            return AuthenticationError(code: LAError.authenticationFailed.rawValue, message: BC_STRING_AUTH_AUTHENTICATION_FAILED)
        case LAError.appCancel:
            return AuthenticationError(code: LAError.appCancel.rawValue, message: BC_STRING_AUTH_APP_CANCEL)
        case LAError.passcodeNotSet:
            return AuthenticationError(code: LAError.passcodeNotSet.rawValue, message: BC_STRING_AUTH_PASSCODE_NOT_SET)
        default:
            return genericAuthenticationError
        }
    }
}
