//
//  NabuAuthenticationService.swift
//  Blockchain
//
//  Created by kevinwu on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

/// Component in charge of authenticating the Nabu user.
final class NabuAuthenticationService {

    static let shared = NabuAuthenticationService()

    private var cachedSessionToken = BehaviorRelay<NabuSessionTokenResponse?>(value: nil)
    private let wallet: Wallet

    // MARK: - Initialization

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    // MARK: - Public Methods

    /// Returns a NabuSessionTokenResponse which is to be used for all KYC endpoints that
    /// require an authenticated KYC user. This function will handle creating a KYC user
    /// if needed, and it will also handle caching and refreshing the KYC session token
    /// as needed.
    ///
    /// Calling this end-point for the 1st time will create a KYC user which will then
    /// be persisted to the user's wallet metadata. The process of creating a KYC user
    /// requires a number of steps:
    ///   (1) a wallet JWT token (obtained by sending the wallet info such as GUID, sharedKey and API code)
    ///   (2) using the JWT token, create a Nabu user
    ///   (3) the created Nabu user is then persisted in the wallet metadata
    ///
    /// - Returns: a Single returning the sesion token
    func getSessionToken() -> Single<NabuSessionTokenResponse> {
        return getOrCreateNabuUserResponse().flatMap {
            self.getSessionTokenIfNeeded(from: $0)
        }
    }

    // MARK: - Private Methods

    private func getSessionTokenIfNeeded(from userResponse: NabuCreateUserResponse) -> Single<NabuSessionTokenResponse> {
        // Use cached session token if not expired, otherwise, request a new one
        guard let sessionToken = cachedSessionToken.value,
            let expiresAt = sessionToken.expiresAt, Date() < expiresAt else {
                let headers: [String: String] = [
                    HttpHeaderField.authorization: userResponse.token,
                    HttpHeaderField.appVersion: Bundle.applicationVersion ?? "",
                    HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp,
                    HttpHeaderField.deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                    HttpHeaderField.walletGuid: self.wallet.guid,
                    HttpHeaderField.walletEmail: self.wallet.getEmail()
                ]
                return KYCNetworkRequest.request(
                    post: .sessionToken(userId: userResponse.userId),
                    parameters: [:],
                    headers: headers,
                    type: NabuSessionTokenResponse.self
                ).do(onSuccess: { [unowned self] in
                    self.cachedSessionToken.accept($0)
                })
        }
        return Single.just(sessionToken)
    }

    /// Retrieves the user's Nabu user ID and API token from the wallet metadata if the Nabu user ID
    /// and api token had already been created. Otherwise, this method will create a new Nabu user ID
    /// and api token from the wallet GUID + email pair followed by updating the wallet metadata
    /// with the retrieved Nabu user ID.
    ///
    /// - Returns: a Single returning the user's Nabu api token
    private func getOrCreateNabuUserResponse() -> Single<NabuCreateUserResponse> {
        guard let kycUserId = wallet.kycUserId(),
            let kycToken = wallet.kycLifetimeToken() else {
                return createAndSaveUserResponse()
        }
        return Single.just(NabuCreateUserResponse(userId: kycUserId, token: kycToken))
    }

    /// Creates a KYC user ID and API token followed by updating the wallet metadata with
    /// the KYC user ID and API token.
    private func createAndSaveUserResponse() -> Single<NabuCreateUserResponse> {
        return WalletService.shared.getSignedRetailToken().flatMap {
            self.createNabuUser(tokenResponse: $0)
        }.flatMap {
            self.saveToWalletMetadata(createUserResponse: $0)
        }
    }

    private func createNabuUser(tokenResponse: SignedRetailTokenResponse) -> Single<NabuCreateUserResponse> {
        guard let token = tokenResponse.token, tokenResponse.success else {
            return Single.error(NabuAuthenticationError.invalidSignedRetailToken)
        }
        return KYCNetworkRequest.request(
            post: .createUser,
            parameters: ["jwt": token],
            headers: nil,
            type: NabuCreateUserResponse.self
        )
    }

    private func saveToWalletMetadata(createUserResponse: NabuCreateUserResponse) -> Single<NabuCreateUserResponse> {
        return Single.create(subscribe: { [unowned self] observer -> Disposable in
            self.wallet.updateKYCUserCredentials(
                withUserId: createUserResponse.userId,
                lifetimeToken: createUserResponse.token,
                success: { _ in
                    observer(.success(createUserResponse))
            }, error: { errorText in
                Logger.shared.error("Failed to update wallet metadata: \(errorText ?? "")")
                observer(.error(NSError(domain: "FailedToUpdateWalletMetadata", code: 0, userInfo: nil)))
            }
            )
            return Disposables.create()
        })
    }
}
