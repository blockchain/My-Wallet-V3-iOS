//
//  KYCState.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct KYCState: Codable, SearchableItem {
    let code: String
    let countryCode: String
    let name: String
    let scopes: [String]?
}

extension KYCState {

    /// Returns a boolean indicating if this state is supported by Blockchain's native KYC
    var isKycSupported: Bool {
        return scopes?.contains(where: { $0.lowercased() == "kyc" }) ?? false
    }
}
