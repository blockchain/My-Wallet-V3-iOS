//
//  BlockchainDataRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Repository for fetching Blockchain data. Accessing properties in this repository
/// will be fetched from the cache (if available), otherwise, data will be fetched over
/// the network and subsequently cached for faster access.
@objc class BlockchainDataRepository: NSObject {

    static let shared = BlockchainDataRepository()

    // MARK: - Public Properties

    var kycUser: Single<KYCUser> {
        // TODO: need to fetch userID from wallet metadata
        // TICKET: IOS-1104
        return fetchData(
            cachedValue: cachedUser,
            networkValue: networkRequest(get: .users(userID: "userID"), type: KYCUser.self)
        )
    }

    var countries: Single<Countries> {
        return fetchData(
            cachedValue: cachedCountries,
            networkValue: networkRequest(get: .listOfCountries, type: Countries.self)
        )
    }

    // MARK: - Private Properties

    private var cachedCountries = Variable<Countries?>(nil)
    private var cachedUser = Variable<KYCUser?>(nil)

    // MARK: - Private Methods

    private func fetchData<ResponseType: Decodable>(
        cachedValue: Variable<ResponseType?>,
        networkValue: Single<ResponseType>
    ) -> Single<ResponseType> {
        return Single.deferred {
            guard let cachedValue = cachedValue.value else {
                return networkValue
            }
            return Single.just(cachedValue)
        }.do(onSuccess: { response in
            cachedValue.value = response
        })
    }

    private func networkRequest<ResponseType: Decodable>(
        get url: KYCNetworkRequest.KYCEndpoints.GET,
        type: ResponseType.Type
    ) -> Single<ResponseType> {
        return Single.create(subscribe: { observer -> Disposable in
            KYCNetworkRequest(get: url, taskSuccess: { responseData in
                do {
                    let response = try JSONDecoder().decode(type.self, from: responseData)
                    observer(.success(response))
                } catch {
                    observer(.error(error))
                }
            }, taskFailure: { error in
                observer(.error(error))
            })
            return Disposables.create()
        })
    }
}
