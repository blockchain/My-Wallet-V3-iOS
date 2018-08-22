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
    let birthday: Date?

    enum CodingKeys: String, CodingKey {
        case firstName = "firstName"
        case lastName = "lastName"
        case birthday = "dob"
    }

    init(firstName: String?, lastName: String?, birthday: Date?) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
    }
}
