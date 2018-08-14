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
    let firstName: String
    let lastName: String
    let email: String
    let birthday: Date

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case firstName = "firstname"
        case lastName = "lastname"
        case email = "email"
        case birthday = "dob"
    }

    init?(id: String?, first: String?, last: String?, email: String?, birthday: Date?) {
        self.identifier = id
        
        if let firstName = first, let lastName = last {
            self.firstName = firstName
            self.lastName = lastName
        } else {
            return nil
        }

        guard let mail = email else { return nil }
        self.email = mail
        guard let date = birthday else { return nil }
        self.birthday = date
    }
}
