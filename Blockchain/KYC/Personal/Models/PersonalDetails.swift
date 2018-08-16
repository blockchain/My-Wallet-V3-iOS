//
//  PersonalDetails.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PersonalDetails: Codable {
    let identifier: String?
    let firstName: String?
    let lastName: String?
    let email: String
    let birthday: Date?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case firstName = "firstname"
        case lastName = "lastname"
        case email = "email"
        case birthday = "dob"
    }

    init?(id: String?, first: String?, last: String?, email: String?, birthday: Date?) {
        guard let mail = email else { return nil }
        self.email = mail
        self.identifier = id
        self.firstName = first
        self.lastName = last
        self.birthday = birthday
    }
}
