//
//  OnfidoUser.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct OnfidoUser: Codable {
    let identifier: String
    let firstName: String
    let lastName: String
    let email: String?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
    }
}
