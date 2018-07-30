//
//  WalletServiceError.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// An error when interacting with the WalletService
internal enum WalletServiceError: Error {
    /// Error parsing a JSON response from the server
    case jsonParseError

    /// A generic error with an optional error message
    //swiftlint:disable next identifier_name
    case generic(message: String?)
}
