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
 Handles biometric and passcode authentication.
 # Usage
 Call either `authenticateUsingBiometrics(andReply:)` or `authenticate(using:andReply:)`
 to request authentication using biometrics or passcode, respectively.
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
     * `authenticateUsingBiometrics(andReply:)`
     * `authenticate(using:andReply:)`
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

    private var authHandler: Handler?

    // MARK: Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        genericAuthenticationError = AuthenticationError(code: Int.min, description: LCStringAuthGenericError)
        super.init()
        WalletManager.shared.authDelegate = self
    }

    /// Deprecate this method once the wallet creation process has been refactored
    func setHandlerForWalletCreation(handler: @escaping Handler) {
        self.authHandler = handler
    }

    // MARK: - Authentication with Biometrics

    /**
     Authenticates the user using biometrics.
     - Parameter handler: The closure for the authentication reply.
     */
    func authenticateUsingBiometrics(andReply handler: @escaping Handler) {
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
     Evaluates whether the device owner can authenticate using biometrics.
     - Returns: A Boolean value that determines whether the policy can be evaluated.
     */
    private func canAuthenticateUsingBiometry() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &preflightError)
    }

    // MARK: - Authentication with Passcode

    /**
     The function used to authenticate the user using a provided passcode.
     - Parameters:
        - payload: The passcode payload used for authenticating the user.
        - handler: The completion handler for the authentication reply.
     */
    func authenticate(using payload: PasscodePayload, andReply handler: @escaping Handler) {

        guard Reachability.hasInternetConnection() else {
            handler(false, AuthenticationError(code: AuthenticationError.ErrorCode.noInternet.rawValue))
            return
        }

        guard payload.password.count != 0 else {
            handler(false, AuthenticationError(
                code: AuthenticationError.ErrorCode.noPassword.rawValue,
                description: LocalizationConstants.Authentication.noPasswordEntered)
            )
            return
        }

        authHandler = handler

        WalletManager.shared.wallet.load(withGuid: payload.guid, sharedKey: payload.sharedKey, password: payload.password)
    }

    // MARK: - Authentication Errors

    /**
     Preflight errors occur **prior** to policy evaluation.
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
     Biometric preflight errors occur **prior** to policy evaluation.
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
     Deprecated preflight errors occur **prior** to policy evaluation.
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
     Inflight error codes that can be returned **during** policy evaluation.
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

extension AuthenticationManager: WalletAuthDelegate {
    func didDecryptWallet(guid: String?, sharedKey: String?, password: String?) {

        // Verify valid GUID and sharedKey
        guard let guid = guid, guid.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            ))
            return
        }

        guard let sharedKey = sharedKey, sharedKey.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey.rawValue,
                description: LocalizationConstants.Authentication.invalidSharedKey
            ))
            return
        }

        BlockchainSettings.App.shared.guid = guid
        BlockchainSettings.App.shared.sharedKey = sharedKey

        clearPinIfNeeded(for: password)
    }

    private func clearPinIfNeeded(for password: String?) {
        // Because we are not storing the password on the device. We record the first few letters of the hashed password.
        // With the hash prefix we can then figure out if the password changed. If so, clear the pin
        // so that the user can reset it
        guard let password = password,
            let passwordSha256 = NSString(string: password).sha256(),
            let passwordPartHash = BlockchainSettings.App.shared.passwordPartHash else {
                return
        }

        let endIndex = passwordSha256.index(passwordSha256.startIndex, offsetBy: min(password.count, 5))
        guard passwordSha256[..<endIndex] != passwordPartHash else {
            return
        }

        BlockchainSettings.App.shared.clearPin()
    }

    func requiresTwoFactorCode() {
        // TODO
    }

    func incorrectTwoFactorCode() {
        // TODO
    }

    func emailAuthorizationRequired() {
        // TODO
    }

    func authenticationError() {
        failAuth()
    }

    func authenticationCompleted() {
        authHandler?(true, nil)
        authHandler = nil
    }

    private func failAuth(withError error: AuthenticationError? = nil) {
        authHandler?(false, error)
        authHandler = nil
    }
}
