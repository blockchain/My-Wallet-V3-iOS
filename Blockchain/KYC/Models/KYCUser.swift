//
//  KYCUser.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCUser: Decodable {
    let personalDetails: PersonalDetails?
    let address: UserAddress?
    let mobile: Mobile?
    let status: KYCAccountStatus

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case status = "kycState"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case mobile = "mobile"
        case mobileVerified = "mobileVerified"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        let lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        let email = try values.decode(String.self, forKey: .email)
        let phoneNumber = try values.decodeIfPresent(String.self, forKey: .mobile)
        let phoneVerified = try values.decodeIfPresent(Bool.self, forKey: .mobileVerified)
        address = try values.decodeIfPresent(UserAddress.self, forKey: .address)

        // TODO: Ask about userID and DOB returning from API
        personalDetails = PersonalDetails(
            id: nil,
            first: firstName,
            last: lastName,
            email: email,
            birthday: Date()
        )
        
        if let number = phoneNumber {
            mobile = Mobile(
                phone: number,
                verified: phoneVerified ?? false
            )
        } else {
            mobile = nil
        }

        // TODO: Ask what the different states are
        // and how they are represented in the API
        status = .inProgress
    }
}

struct Mobile: Decodable {
    let phone: String
    let verified: Bool

    enum CodingKeys: String, CodingKey {
        case phone = "mobile"
        case verified = "mobileVerified"
    }
}
