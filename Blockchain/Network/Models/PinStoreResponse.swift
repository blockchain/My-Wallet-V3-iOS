//
//  PinStoreResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct PinStoreResponse {
    enum StatusCode: Int {
        case success = 0
        case deleted = 1 // Pin retry succeeded
        case incorrect = 2 // Incorrect pin
    }

    // This is a status code from the server
    let code: Int?

    // This is an error string from the server or nil
    let error: String?

    // The PIN decryption value from the server
    let pinDecryptionValue: String?

    /// Pin code lookup key
    let key: String?

    /// Encryption string
    let value: String?
}

extension PinStoreResponse {
    var statusCode: StatusCode? {
        guard let code = code else {
            return nil
        }
        return StatusCode(rawValue: code)
    }

    init(response: [AnyHashable: Any]) {
        self.code = response["code"] as? Int
        self.error = response["error"] as? String
        self.pinDecryptionValue = response["success"] as? String
        self.key = response["key"] as? String
        self.value = response["value"] as? String
    }
}
