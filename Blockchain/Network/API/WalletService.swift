//
//  WalletService.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

typealias JSON = [String: Any]

/// Service that interacts with the Blockchain API
class WalletService {
    static let shared = WalletService()

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    // MARK: - Public

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: an Observable returning the response
    func validatePin(_ pinPayload: PinPayload) -> Single<GetPinResponse> {
        return pinStore(pinPayload: pinPayload, method: "get").map {
            guard let responseJson = $1 as? JSON else {
                let errorMessage = $1 as? String ?? ""
                throw PinStoreError(errorMessage: errorMessage)
            }
            return GetPinResponse(response: responseJson)
        }
    }

    // MARK: - Private

    private func pinStore(
        pinPayload: PinPayload,
        method: String,
        value: String? = nil
    ) -> Single<(HTTPURLResponse, Any)> {
        var parameters = [
            "format": "json",
            "method": method,
            "pin": pinPayload.pinCode,
            "key": pinPayload.pinKey,
            "api_code": BlockchainAPI.Parameters.apiCode
        ]
        if let value = value {
            parameters[value] = value
        }
        return networkManager.requestJsonOrString(
            BlockchainAPI.shared.pinStore,
            method: .post,
            parameters: parameters
        ).asSingle()
    }
}
