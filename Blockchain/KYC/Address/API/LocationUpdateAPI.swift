//
//  LocationUpdateAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias LocationUpdateCompletion = ((Error?) -> Void)

enum LocationUpdateError: Error {
    case noPostalCode
    case noAddress
    case noCity
    case noCountry
}

protocol LocationUpdateAPI {
    func updateAddress(address: UserAddress, for userID: String, with completion: @escaping LocationUpdateCompletion)
}

class LocationUpdateService: NSObject, LocationUpdateAPI {
    
    func updateAddress(address: UserAddress, for userID: String, with completion: @escaping LocationUpdateCompletion) {
        guard let value = address.stringRepresentation() else {
            completion(NetworkError.generic(message: "Failed to parse address"))
            return
        }

        let payload = ["address": value]

        KYCNetworkRequest(
            put: .updateAddress(userId: userID),
            parameters: payload,
            taskSuccess: { _ in
                completion(nil)
        }) { (error) in
            completion(error)
        }
    }
}
