// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Extensions
import Foundation

public enum DeviceVerificationServiceError: Error, Equatable, TimeoutFailure {
    // email request error
    case recaptchaError(GoogleRecaptchaError)

    // authorize approve error
    case expiredEmailCode

    // wallet info polling error
    case missingWalletInfo
    case missingSessionToken

    // other network errors
    case networkError(NetworkError)
    case timeout

    public static func == (lhs: DeviceVerificationServiceError, rhs: DeviceVerificationServiceError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

/// `DeviceVerificationServiceAPI` is the interface the UI should use the authentication service APIs.
public protocol DeviceVerificationServiceAPI {

    /// Sends a verification email to the user's email address. Thie will trigger the send GUID reminder endpoint and user will receive a link to verify their device in their inbox if they have an account registered with the email
    /// - Parameters: emailAddress: The email address of the user
    /// - Returns: A combine `Publisher` that emits an EmptyNetworkResponse on success or NetworkError on failure
    func sendDeviceVerificationEmail(to emailAddress: String)
        -> AnyPublisher<Void, DeviceVerificationServiceError>

    /// Authorize the login to the associated email identified by the email code. The email code is received by decrypting the base64 information encrypted in the magic link from the device verification email
    /// - Parameters: emailCode: The email code for the authorization
    /// - Returns: A combine `Publisher` that emits an EmptyNetworkResponse on success or NetworkError on failure
    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError>

    /// Decodes the base64 string component from the deeplink, and returns the wallet info
    /// - Parameters: deeplink: The url link received
    /// - Returns: A combine `Publisher` that emits an WalletInfo struct on success or WalletInfoError on failure
    func handleLoginRequestDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError>

    /// An alternative way to retrieve wallet info through polling
    /// - Returns: A combine `Publisher` that emits an `Result<WalletInfo, WalletInfoPollingError>` or DeviceVerificationServiceError on failure
    func pollForWalletInfo() -> AnyPublisher<Result<WalletInfo, WalletInfoPollingError>, DeviceVerificationServiceError>

    /// Authorize the login request from another device
    /// - Parameters:
    ///  - sessionToken: the session token from another device
    ///  - payload: the base64 email link payload from a magic link generated from another device
    ///  - confirmDevice: to authorize the device or not
    /// - Returns: A combine `Publisher` that returns void on success or `AuthorizeVerifyDeviceError` on failure
    func authorizeVerifyDevice(
        from sessionToken: String,
        payload: String,
        confirmDevice: Bool?
    ) -> AnyPublisher<Void, AuthorizeVerifyDeviceError>
}
