//
//  KYCUpdateMobileRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for updating the user's mobile number during KYC
struct KYCUpdateMobileRequest: Codable {
    let mobile: String

    enum CodingKeys: String, CodingKey {
        case mobile
    }

    init(mobile: String) {
        self.mobile = mobile
    }
}
