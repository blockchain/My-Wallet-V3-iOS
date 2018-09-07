//
//  NabuCreateUserResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model encapsulating the network response from the `/users` endpoint.
struct NabuCreateUserResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case userId
        case token
    }

    let userId: String
    let token: String

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        token = try values.decode(String.self, forKey: .token)
    }

    init(userId: String, token: String) {
        self.userId = userId
        self.token = token
    }
}
