//
//  WalletService.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Service that interacts with the Blockchain API
@objc class WalletService: NSObject {
    static let shared = WalletService()

    @objc class func sharedInstance() -> WalletService { return shared }

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    // MARK: - Private Properties

    private var cachedWalletOptions = Variable<WalletOptions?>(nil)

    private var networkFetchedWalletOptions: Single<WalletOptions> {
        return networkManager.requestJsonOrString(
            BlockchainAPI.shared.walletOptionsUrl,
            method: .get
        ).map {
            guard $0.statusCode == 200 else {
                throw NetworkError.generic(message: nil)
            }
            guard let json = $1 as? JSON else {
                throw NetworkError.jsonParseError
            }
            return WalletOptions(json: json)
        }.do(onSuccess: { [weak self] in
            self?.cachedWalletOptions.value = $0
        })
    }

    // MARK: - Public

    /// A Single returning the WalletOptions which contains dynamic flags for configuring the app.
    /// If WalletOptions has already been fetched, this property will return the cached value
    var walletOptions: Single<WalletOptions> {
        return Single.deferred { [unowned self] in
            guard let cachedValue = self.cachedWalletOptions.value else {
                return self.networkFetchedWalletOptions
            }
            return Single.just(cachedValue)
        }
    }

    func isCountryInHomebrewRegion(countryCode: String) -> Single<Bool> {
        return networkManager.requestJsonOrString(
            BlockchainAPI.KYC.countries,
            method: .get
        ).map {
            guard $0.statusCode == 200 else {
                throw NetworkError.generic(message: nil)
            }
            guard let json = $1 as? JSON else {
                throw NetworkError.jsonParseError
            }
            return json.keys.contains(countryCode)
        }
    }

    /// Creates a new pin in the remote pin store
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: a Single returning the response
    func createPin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        return pinStore(pinPayload: pinPayload, method: "put")
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: an Single returning the response
    func validatePin(_ pinPayload: PinPayload) -> Single<PinStoreResponse> {
        return pinStore(pinPayload: pinPayload, method: "get")
    }

    // MARK: - Private

    private func pinStore(
        pinPayload: PinPayload,
        method: String
    ) -> Single<PinStoreResponse> {
        var parameters = [
            "format": "json",
            "method": method,
            "pin": pinPayload.pinCode,
            "key": pinPayload.pinKey,
            "api_code": BlockchainAPI.Parameters.apiCode
        ]
        if let value = pinPayload.pinValue {
            parameters["value"] = value
        }
        return networkManager.requestJsonOrString(
            BlockchainAPI.shared.pinStore,
            method: .post,
            parameters: parameters
        ).map {
            guard let responseJson = $1 as? JSON else {
                let errorMessage = $1 as? String
                throw NetworkError.generic(message: errorMessage)
            }
            return PinStoreResponse(response: responseJson)
        }
    }
}
