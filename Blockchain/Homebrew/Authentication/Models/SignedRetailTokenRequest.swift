//
//  SignedRetailTokenRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for the request payload for the `/wallet/signed-retail-token` endpoint.
struct SignedRetailTokenRequest: Codable {
    let apiCode: String
    let sharedKey: String
    let walletGuid: String

    enum CodingKeys: String, CodingKey {
        case apiCode = "api_code"
        case sharedKey = "sharedKey"
        case walletGuid = "guid"
    }
}

extension SignedRetailTokenRequest {
    var toDictionary: [String: String] {
        return [
            CodingKeys.apiCode.rawValue: apiCode,
            CodingKeys.sharedKey.rawValue: sharedKey,
            CodingKeys.walletGuid.rawValue: walletGuid
        ]
    }
}
