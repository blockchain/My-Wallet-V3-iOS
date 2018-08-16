//
//  KYCUser.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCUser: Decodable {

    enum UserState: String {
        case none = "NONE"
        case created = "CREATED"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    let personalDetails: PersonalDetails?
    let address: UserAddress?
    let mobile: Mobile?
    let status: KYCAccountStatus
    let state: UserState

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case status = "kycState"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case mobile = "mobile"
        case mobileVerified = "mobileVerified"
        case identifier = "id"
        case state = "state"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let userID = try values.decodeIfPresent(String.self, forKey: .identifier)
        let firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        let lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        let email = try values.decode(String.self, forKey: .email)
        let phoneNumber = try values.decodeIfPresent(String.self, forKey: .mobile)
        let phoneVerified = try values.decodeIfPresent(Bool.self, forKey: .mobileVerified)
        let statusValue = try values.decode(String.self, forKey: .status)
        let userState = try values.decode(String.self, forKey: .state)
        address = try values.decodeIfPresent(UserAddress.self, forKey: .address)

        personalDetails = PersonalDetails(
            id: userID,
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

        status = KYCAccountStatus(rawValue: statusValue) ?? .none
        state = UserState(rawValue: userState) ?? .none
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
