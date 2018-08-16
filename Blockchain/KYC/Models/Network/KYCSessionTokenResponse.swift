//
//  KYCSessionTokenResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model encapsulating the network response from the `/auth` endpoint.
struct KYCSessionTokenResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userId = "userId"
        case token = "token"
        case isActive = "isActive"
        case expiresAt = "expiresAt"
        case insertedAt = "insertedAt"
        case updatedAt = "updatedAt"
    }

    let identifier: String
    let userId: String
    let token: String
    let isActive: Bool
    let expiresAt: Date
    let insertedAt: Date
    let updatedAt: Date

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        userId = try values.decode(String.self, forKey: .userId)
        token = try values.decode(String.self, forKey: .token)
        isActive = try values.decode(Bool.self, forKey: .isActive)
        // TODO: Parse expiresAt, insertedAt, updatedAt
    }
}
