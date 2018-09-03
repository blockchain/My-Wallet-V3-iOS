//
//  KYCAuthenticationService.swift
//  Blockchain
//
//  Created by kevinwu on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

/// Component in charge of authenticating the KYC user.
final class KYCAuthenticationService {

    static let shared = KYCAuthenticationService()

    private var cachedSessionToken = BehaviorRelay<KYCSessionTokenResponse?>(value: nil)
    private let wallet: Wallet

    // MARK: - Initialization

    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }

    // MARK: - Public Methods

    /// Returns a KYCSessionTokenResponse which is to be used for all KYC endpoints that
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
    func getKycSessionToken() -> Single<KYCSessionTokenResponse> {
        return getOrCreateKYCUserResponse().flatMap {
            self.getKycSessionTokenIfNeeded(from: $0)
        }
    }

    // MARK: - Private Methods

    private func getKycSessionTokenIfNeeded(from userResponse: KYCCreateUserResponse) -> Single<KYCSessionTokenResponse> {
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
                    type: KYCSessionTokenResponse.self
                ).do(onSuccess: { [unowned self] in
                    self.cachedSessionToken.accept($0)
                })
        }
        return Single.just(sessionToken)
    }

    /// Retrieves the user's KYC user ID and API token from the wallet metadata if the KYC user ID
    /// and api token had already been created. Otherwise, this method will create a new KYC user ID
    /// and api token from the wallet GUID + email pair followed by updating the wallet metadata
    /// with the retrieved KYC user ID.
    ///
    /// - Returns: a Single returning the user's KYC api token
    private func getOrCreateKYCUserResponse() -> Single<KYCCreateUserResponse> {
        guard let kycUserId = wallet.kycUserId(),
            let kycToken = wallet.kycLifetimeToken() else {
                return createAndSaveUserResponse()
        }
        return Single.just(KYCCreateUserResponse(userId: kycUserId, token: kycToken))
    }

    /// Creates a KYC user ID and API token followed by updating the wallet metadata with
    /// the KYC user ID and API token.
    private func createAndSaveUserResponse() -> Single<KYCCreateUserResponse> {
        return getSignedRetailToken().flatMap {
            self.createKycUser(tokenResponse: $0)
        }.flatMap {
            self.saveToWalletMetadata(createUserResponse: $0)
        }
    }

    private func getSignedRetailToken() -> Single<SignedRetailTokenResponse> {

        // Construct URL
        let appSettings = BlockchainSettings.App.shared

        guard let walletGuid = appSettings.guid else {
            return Single.error(KYCAuthenticationError.invalidGuid)
        }
        guard let sharedKey = appSettings.sharedKey else {
            return Single.error(KYCAuthenticationError.invalidSharedKey)
        }

        let requestPayload = SignedRetailTokenRequest(
            apiCode: BlockchainAPI.Parameters.apiCode,
            sharedKey: sharedKey,
            walletGuid: walletGuid
        )
        guard let baseUrl = URL(string: BlockchainAPI.shared.signedRetailTokenUrl),
            let url = URL.endpoint(baseUrl, pathComponents: nil, queryParameters: requestPayload.toDictionary),
            let urlRequest = try? URLRequest(url: url, method: .get) else {
                return Single.error(KYCAuthenticationError.invalidUrl)
        }

        // Initiate request
        return NetworkManager.shared.request(urlRequest, responseType: SignedRetailTokenResponse.self)
    }

    private func createKycUser(tokenResponse: SignedRetailTokenResponse) -> Single<KYCCreateUserResponse> {
        guard let token = tokenResponse.token, tokenResponse.success else {
            return Single.error(KYCAuthenticationError.invalidSignedRetailToken)
        }
        return KYCNetworkRequest.request(
            post: .createUser,
            parameters: ["jwt": token],
            headers: nil,
            type: KYCCreateUserResponse.self
        )
    }

    private func saveToWalletMetadata(createUserResponse: KYCCreateUserResponse) -> Single<KYCCreateUserResponse> {
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
