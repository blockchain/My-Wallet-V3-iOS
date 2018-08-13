//
//  PostalAddress.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct PostalAddress {
    let street: String?
    let streetNumber: String?
    let postalCode: String?
    let country: String?
    let countryCode: String?
    let city: String?
    let state: String?
    var unit: String?
}

// TICKET: IOS-1145 - Combine PostalAddress and UserAddress models.
struct UserAddress: Codable {
    let lineOne: String
    let lineTwo: String
    let postalCode: String
    let city: String
    let state: String?
    let country: String

    enum CodingKeys: String, CodingKey {
        case lineOne = "line1"
        case lineTwo = "line2"
        case postalCode = "postCode"
        case city = "city"
        case state = "state"
        case country = "country"
    }
}

extension UserAddress: Equatable {
    static func ==(lhs: UserAddress, rhs: UserAddress) -> Bool {
        return lhs.lineOne == rhs.lineOne &&
            lhs.lineTwo == rhs.lineTwo &&
            lhs.postalCode == rhs.postalCode &&
            lhs.city == rhs.city &&
            lhs.country == rhs.country &&
            lhs.state == rhs.state
    }
}

extension UserAddress: Hashable {
    var hashValue: Int {
        return lineOne.hashValue ^
            lineTwo.hashValue ^
            postalCode.hashValue ^
            city.hashValue ^
            country.hashValue
    }
}
