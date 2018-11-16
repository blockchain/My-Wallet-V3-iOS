//
//  KYCVerifyIdentityInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class KYCVerifyIdentityInteractor {
    private let authentication: NabuAuthenticationService

    private var cache = [String: [KYCDocumentType]]()

    init(authentication: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authentication = authentication
    }

    func supportedDocumentTypes(_ countryCode: String) -> Single<[KYCDocumentType]> {
        // Check cache
        if let types = cache[countryCode] {
            return Single.just(types)
        }

        // If not available, request supported document types
        return authentication.getSessionToken().flatMap { tokenResponse -> Single<KYCSupportedDocumentsResponse> in
            let headers = [HttpHeaderField.authorization: tokenResponse.token]
            return KYCNetworkRequest.request(
                get: .supportedDocuments,
                pathComponents: ["kyc", "supported-documents", countryCode],
                headers: headers,
                type: KYCSupportedDocumentsResponse.self
            )
        }
        .map {
            return $0.documentTypes
        }
        .do(onSuccess: { [weak self] types in
            self?.cache[countryCode] = types
        })
    }
}
