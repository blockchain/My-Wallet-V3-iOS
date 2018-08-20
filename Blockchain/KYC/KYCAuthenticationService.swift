//
//  KYCAuthenticationService.swift
//  Blockchain
//
//  Created by kevinwu on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Component in charge of authenticating the KYC user.
final class KYCAuthenticationService {

    private struct Keys {
        static let email = "email"
        static let guid = "walletGuid"
        static let userId = "userId"
    }

    static let shared = KYCAuthenticationService()

    private let wallet: Wallet

    // MARK: - Initialization

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    // MARK: - Public Methods

    /// Returns a KYCSessionTokenResponse which is to be used for all KYC endpoints that
    /// require an authenticated KYC user.
    ///
    /// - Returns: a Single returning the sesion token
    func getKycSessionToken() -> Single<KYCSessionTokenResponse> {
        // TODO: cache this
        // TODO: pass in valid device ID
        return getOrCreateApiTokenResponse().flatMap { [unowned self] apiToken in
            let headers: [String: String] = [
                HttpHeaderField.authorization: apiToken.token,
                HttpHeaderField.appVersion: Bundle.applicationVersion ?? "",
                HttpHeaderField.clientType: HttpHeaderValue.clientTypeIos,
                HttpHeaderField.deviceId: "ID GOES HERE",
                HttpHeaderField.walletGuid: self.wallet.guid,
                HttpHeaderField.walletEmail: self.wallet.getEmail()
            ]
            return KYCNetworkRequest.request(
                post: .sessionToken(userId: apiToken.userId),
                parameters: [:],
                headers: headers,
                type: KYCSessionTokenResponse.self
            )
        }
    }

    // MARK: - Private Methods

    /// Retrieves the user's KYC user ID and API token from the wallet metadata if the KYC user ID
    /// and api token had already been created. Otherwise, this method will create a new KYC user ID
    /// and api token from the wallet GUID + email pair followed by updating the wallet metadata
    /// with the retrieved KYC user ID.
    ///
    /// - Returns: a Single returning the user's KYC api token
    private func getOrCreateApiTokenResponse() -> Single<KYCApiTokenResponse> {
        guard let kycUserId = wallet.kycUserId(),
            let kycToken = wallet.kycLifetimeToken() else {
                return createAndSaveApiTokenResponse()
        }
        return Single.just(KYCApiTokenResponse(userId: kycUserId, token: kycToken))
    }

    /// Creates a KYC user ID and API token followed by updating the wallet metadata with
    /// the KYC user ID and API token.
    private func createAndSaveApiTokenResponse() -> Single<KYCApiTokenResponse> {
        return createKycUserId().flatMap {
            self.createKycApiToken(from: $0)
        }.flatMap {
            self.saveToWalletMetadata(apiTokenResponse: $0)
        }
    }

    private func createKycUserId() -> Single<KYCCreateUserResponse> {
        // prevents a crash when backgrounding the app when in the middle of KYC
       if UIApplication.shared.applicationState != .active {
            return KYCNetworkRequest.request(
                post: .registerUser,
                parameters: [:],
                headers: [:],
                type: KYCCreateUserResponse.self
            )
        }
        
        let parameters: [String: String] = [
            "email": wallet.getEmail(),
            "walletGuid": wallet.guid
        ]
        let headers: [String: String] = [
            HttpHeaderField.authorization: ""
        ]
        return KYCNetworkRequest.request(
            post: .registerUser,
            parameters: parameters,
            headers: headers,
            type: KYCCreateUserResponse.self
        )
    }

    private func createKycApiToken(from response: KYCCreateUserResponse) -> Single<KYCApiTokenResponse> {
        let headers: [String: String] = [
            HttpHeaderField.authorization: "",
            HttpHeaderField.walletGuid: wallet.guid,
            HttpHeaderField.walletEmail: wallet.getEmail()
        ]
        return KYCNetworkRequest.request(
            post: .apiKey(userId: response.userId),
            parameters: [:],
            headers: headers,
            type: KYCApiTokenResponse.self
        )
    }

    private func saveToWalletMetadata(apiTokenResponse: KYCApiTokenResponse) -> Single<KYCApiTokenResponse> {
        return Single.create(subscribe: { [unowned self] observer -> Disposable in
            self.wallet.updateKYCUserCredentials(
                withUserId: apiTokenResponse.userId,
                lifetimeToken: apiTokenResponse.token,
                success: { _ in
                    observer(.success(apiTokenResponse))
                }, error: { errorText in
                    Logger.shared.error("Failed to update wallet metadata: \(errorText ?? "")")
                    observer(.error(NSError(domain: "FailedToUpdateWalletMetadata", code: 0, userInfo: nil)))
                }
            )
            return Disposables.create()
        })
    }
}
