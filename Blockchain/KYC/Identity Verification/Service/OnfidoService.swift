//
//  OnfidoService.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

enum OnfidoError: Error {
    case invalidKycUser
}

class OnfidoService {

    private let authService: KYCAuthenticationService

    init(authService: KYCAuthenticationService = KYCAuthenticationService.shared) {
        self.authService = authService
    }

    // MARK: - Public

    /// Creates an OnfidoUser and returns the credentials for the Onfido API.
    ///
    /// - Parameter user: the KYCUser
    /// - Returns: a Single returning the OnfidoUser and the Onfido credentials
    func createUserAndCredentials(user: KYCUser) -> Single<(OnfidoUser, OnfidoCredentials)> {
        return getOnfidoCredentials().flatMap { [unowned self] credentials in
            return self.createOnfidoUser(from: user, token: credentials).map {
                return ($0, credentials)
            }
        }
    }

    /// Submits the Onfido user to Blockchain to complete KYC processing.
    /// This should be invoked upon successfully uploading the identity docs to Onfido.
    ///
    /// - Parameter user: the OnfidoUser
    /// - Returns: a Completable
    func submitVerification(_ user: OnfidoUser) -> Completable {
        return authService.getKycSessionToken().flatMapCompletable { token in
            let headers = [HttpHeaderField.authorization: token.token]
            let payload = [
                "applicantId": user.identifier,
                HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp
            ]
            return KYCNetworkRequest.request(
                post: .submitVerification,
                parameters: payload,
                headers: headers
            )
        }
    }

    // MARK: - Private

    private func getOnfidoCredentials() -> Single<OnfidoCredentials> {
        return authService.getKycSessionToken().flatMap { token in
            let headers = [HttpHeaderField.authorization: token.token]
            return KYCNetworkRequest.request(get: .credentialsForOnfido, headers: headers, type: OnfidoCredentials.self)
        }
    }

    /// Creates a new OnfidoUser from a KYCUser.
    ///
    /// - Parameters:
    ///   - user: the KYCUser
    ///   - token: the Onfido token
    /// - Returns: a Single returning the created OnfidoUser
    private func createOnfidoUser(from user: KYCUser, token: OnfidoCredentials) -> Single<OnfidoUser> {
        guard let request = OnfidoCreateApplicantRequest(kycUser: user) else {
            return Single.error(OnfidoError.invalidKycUser)
        }
        do {
            let payload = try request.toDictionary()
            let headers = [
                HttpHeaderField.authorization: "Token token=\(token.key)"
            ]
            return NetworkManager.shared.requestData(
                "https://api.onfido.com/v2/applicants",
                method: .post,
                parameters: payload,
                headers: headers
            ).map { (response, result) in
                guard (200...299).contains(response.statusCode) else {
                    throw NetworkError.badStatusCode
                }
                return try JSONDecoder().decode(OnfidoUser.self, from: result)
            }
        } catch {
            return Single.error(error)
        }
    }
}
