//
//  KYCUpdatePersonalDetailsRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Struct for updating the user's personal details during KYC
struct KYCUpdatePersonalDetailsRequest: Codable {
    let firstName: String?
    let lastName: String?
    let dob: Date?

    enum CodingKeys: String, CodingKey {
        case firstName = "firstName"
        case lastName = "lastName"
        case dob = "dob"
    }

    init(firstName: String?, lastName: String?, dob: Date?) {
        self.firstName = firstName
        self.lastName = lastName
        self.dob = dob
    }
}
