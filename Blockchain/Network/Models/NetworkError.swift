//
//  NetworkError.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// An error when interacting with the NetworkError
internal enum NetworkError: Error {
    /// Error parsing a JSON response from the server
    case jsonParseError

    /// A generic error with an optional error message
    case generic(message: String?)

    /// An error when the response status code is not in the 200s
    case badStatusCode
}
