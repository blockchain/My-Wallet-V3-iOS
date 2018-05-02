//
//  AuthenticationError.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Represents an authentication error.

 Set **description** to `nil` to indicate that the error should be handled silently.
 */
internal struct AuthenticationError {
    enum ErrorCode: Int {
        case noInternet = 300
        case noPassword
        case errorDecryptingWallet
        case invalidSharedKey
        case failedToLoadWallet
        case invalidTwoFactorType
        case emailAuthorizationRequired
        case unknown
    }

    let code: Int
    let description: String?

    /**
     - Parameters:
        - code: The code associated with the error object.
        - description: The description associated with the error object.
     */
    init(code: Int, description: String? = nil) {
        self.code = code
        self.description = description
    }
}
