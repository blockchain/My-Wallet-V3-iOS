//
//  SignedRetailTokenResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for the response received for the `/wallet/signed-retail-token` endpoint.
struct SignedRetailTokenResponse: Codable {
    let success: Bool
    let token: String?
    let error: String?
}
