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
    let code: Int
    let description: String?
    /**
     - Parameters:
        - code: The numeric code associated with the error object.
        - description: The description associated with the error object.
     */
    init(code: Int, description: String?) {
        self.code = code
        self.description = description
    }
}
