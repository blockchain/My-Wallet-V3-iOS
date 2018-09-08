//
//  OnfidoCreateApplicantRequest.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for sending a request to create a new OnfidoUser object
struct OnfidoCreateApplicantRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
    }
}

extension OnfidoCreateApplicantRequest {
    init?(kycUser: NabuUser) {
        guard let personalDetails = kycUser.personalDetails,
            let first = personalDetails.firstName,
            let last = personalDetails.lastName else {
                return nil
        }
        self.firstName = first
        self.lastName = last
        self.email = personalDetails.email
    }
}
