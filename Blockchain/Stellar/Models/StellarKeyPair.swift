//
//  StellarKeyPair.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A Stellar public/private key pair
struct StellarKeyPair {
    /// The stellar account ID
    let accountId: String

    /// The secret used to create the public/private key pair
    let secret: String
}
