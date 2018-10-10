//
//  KYCCountry.swift
//  Blockchain
//
//  Created by Maurice A. on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCCountry: Codable, SearchableItem {
    let code: String
    let name: String
    let regions: [String]
    let scopes: [String]?
    let states: [String]
}

extension KYCCountry {

    /// Returns a boolean indicating if this country is supported by Blockchain's native KYC
    var isKycSupported: Bool {
        return scopes?.contains(where: { $0.lowercased() == "kyc" }) ?? false
    }

    /// The URL path components to get all the states for this country
    var urlPathComponentsForState: [String] {
        return ["countries", self.code, "states"]
    }
}
