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

struct UserAddress: Encodable {
    let lineOne: String
    let lineTwo: String
    let postalCode: String
    let city: String
    let country: String
}

extension UserAddress {
    func stringRepresentation() -> String? {
        do {
            let data = try JSONEncoder().encode(self)
            let value = String(data: data, encoding: .utf8)
            return value
        } catch {
            return nil
        }
    }
}
