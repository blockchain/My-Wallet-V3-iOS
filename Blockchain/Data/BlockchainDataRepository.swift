//
//  BlockchainDataRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift
import PlatformKit

/// Repository for fetching Blockchain data. Accessing properties in this repository
/// will be fetched from the cache (if available), otherwise, data will be fetched over
/// the network and subsequently cached for faster access.
@objc class BlockchainDataRepository: NSObject {

    static let shared = BlockchainDataRepository()

    private let authenticationService: NabuAuthenticationService

    init(authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authenticationService = authenticationService
    }

    // MARK: - Public Properties

    /// An Observable emitting the authenticated NabuUser. This Observable will first emit a value
    /// from the cache, if available, followed by the value over the network.
    var nabuUser: Observable<NabuUser> {
        return fetchDataStartingWithCache(
            cachedValue: cachedUser,
            networkValue: fetchNabuUser()
        )
    }

    var countries: Single<Countries> {
        let countriesFetchedOverNetwork = KYCNetworkRequest.request(
            get: .listOfCountries,
            type: Countries.self
        ).map { countries -> Countries in
            countries.sorted(by: { $0.name.uppercased() < $1.name.uppercased() })
        }

        return fetchData(
            cachedValue: cachedCountries,
            networkValue: countriesFetchedOverNetwork
        )
    }

    var tiers: Observable<KYCUserTiersResponse> {
        guard let baseURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else {
            return Observable.error(NetworkError.generic(message: "Could not get endpoint"))
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["kyc", "tiers"],
            queryParameters: nil
        ) else {
            return Observable.error(NetworkError.generic(message: "Could not get endpoint"))
        }

        let tiersFetchedOverNetwork = authenticationService.getSessionToken().flatMap { token in
            return NetworkRequest.GET(
                url: endpoint,
                body: nil,
                headers: [HttpHeaderField.authorization: token.token],
                type: KYCUserTiersResponse.self
            )
        }

        return fetchDataStartingWithCache(
            cachedValue: cachedTiers,
            networkValue: tiersFetchedOverNetwork
        )
    }

    // MARK: - Private Properties

    private var cachedCountries = BehaviorRelay<Countries?>(value: nil)

    private var cachedUser = BehaviorRelay<NabuUser?>(value: nil)

    private var cachedTiers = BehaviorRelay<KYCUserTiersResponse?>(value: nil)

    // MARK: - Public Methods

    /// Prefetches data so that it can be cached
    func prefetchData() {
        _ = Observable.zip(
            nabuUser,
            countries.asObservable(),
            tiers
        ).subscribe()
    }

    /// Clears cached data in this repository
    func clearCache() {
        cachedUser = BehaviorRelay<NabuUser?>(value: nil)
        cachedCountries = BehaviorRelay<Countries?>(value: nil)
    }

    /// Fetches the NabuUser over the network and updates the cached NabuUser if successful
    ///
    /// - Returns: the fetched NabuUser
    func fetchNabuUser() -> Single<NabuUser> {
        return authenticationService.getSessionToken().flatMap { token in
            let headers = [HttpHeaderField.authorization: token.token]
            return KYCNetworkRequest.request(get: .currentUser, headers: headers, type: NabuUser.self)
        }.do(onSuccess: { [weak self] response in
            self?.cachedUser.accept(response)
        })
    }

    // MARK: - Private Methods

    private func fetchDataStartingWithCache<ResponseType: Decodable>(
        cachedValue: BehaviorRelay<ResponseType?>,
        networkValue: Single<ResponseType>
    ) -> Observable<ResponseType> {
        let networkObservable = networkValue.asObservable()
        guard let cachedValue = cachedValue.value else {
            return networkObservable
        }
        return networkObservable.startWith(cachedValue)
    }

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
