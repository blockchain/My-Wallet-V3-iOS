//
//  BlockchainDataRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

/// Repository for fetching Blockchain data. Accessing properties in this repository
/// will be fetched from the cache (if available), otherwise, data will be fetched over
/// the network and subsequently cached for faster access.
@objc class BlockchainDataRepository: NSObject {

    static let shared = BlockchainDataRepository()

    private let authenticationService: KYCAuthenticationService

    init(authenticationService: KYCAuthenticationService = KYCAuthenticationService.shared) {
        self.authenticationService = authenticationService
    }

    // MARK: - Public Properties

    var kycUser: Single<KYCUser> {
        return fetchData(
            cachedValue: cachedUser,
            networkValue: authenticationService.getKycSessionToken().flatMap { token in
                let headers = [HttpHeaderField.authorization: token.token]
                return KYCNetworkRequest.request(get: .currentUser, headers: headers, type: KYCUser.self)
            }
        )
    }

    var countries: Single<Countries> {
        return fetchData(
            cachedValue: cachedCountries,
            networkValue: KYCNetworkRequest.request(get: .listOfCountries, type: Countries.self)
        )
    }

    var onfidoCredentials: Single<[VerificationPayload]> {
        return fetchData(
            cachedValue: cachedProviderCredentials,
            networkValue: authenticationService.getKycSessionToken().flatMap { token in
                let headers = [HttpHeaderField.authorization: token.token]
                return KYCNetworkRequest.request(get: .credentials, headers: headers, type: [VerificationPayload].self)
        })
    }

    // MARK: - Private Properties

    private var cachedCountries = BehaviorRelay<Countries?>(value: nil)

    private var cachedUser = BehaviorRelay<KYCUser?>(value: nil)

    private var cachedProviderCredentials = BehaviorRelay<[VerificationPayload]?>(value: nil)

    // MARK: - Public Methods

    /// Clears cached data in this repository
    func clearCache() {
        cachedUser = BehaviorRelay<KYCUser?>(value: nil)
        cachedCountries = BehaviorRelay<Countries?>(value: nil)
        cachedProviderCredentials = BehaviorRelay<[VerificationPayload]?>(value: nil)
    }

    // MARK: - Private Methods

    private func fetchData<ResponseType: Decodable>(
        cachedValue: BehaviorRelay<ResponseType?>,
        networkValue: Single<ResponseType>
    ) -> Single<ResponseType> {
        return Single.deferred {
            guard let cachedValue = cachedValue.value else {
                return networkValue
            }
            return Single.just(cachedValue)
        }.do(onSuccess: { response in
            cachedValue.accept(response)
        })
    }
}
