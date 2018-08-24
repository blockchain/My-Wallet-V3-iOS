//
//  KYCUpdateAddressRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for updating the user's address during KYC
struct KYCUpdateAddressRequest: Codable {
    let address: UserAddress

    enum CodingKeys: String, CodingKey {
        case address
    }

    init(address: UserAddress) {
        self.address = address
    }
}
