//
//  KYCCreateUserResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model encapsulating the network response from the `/internal/users` endpoint.
struct KYCCreateUserResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case userId
    }

    let userId: String

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
    }
}
