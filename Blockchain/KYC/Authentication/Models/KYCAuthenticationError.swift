//
//  KYCAuthenticationError.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates errors that can occur during the KYC authentication flow
enum KYCAuthenticationError: Error {
    case invalidUrl

    case invalidGuid

    case invalidSharedKey

    case invalidSignedRetailToken
}
