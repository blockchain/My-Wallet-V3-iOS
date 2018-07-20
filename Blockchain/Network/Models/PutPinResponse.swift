//
//  PutPinResponse.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// REMOVE
struct PutPinResponse {
    /// The status code from the server
    let code: Int?

    /// Error string from the server, if any
    let error: String?

    /// Pin code lookup key
    let key: String

    /// Encryption string
    let value: String

    var isStatusCodeOk: Bool {
        guard let code = code else {
            return false
        }
        return code == 0
    }
}

extension PutPinResponse {
    init(response: [AnyHashable: Any]) {
        self.code = response["code"] as? Int
        self.error = response["error"] as? String
        self.key = response["key"] as! String
        self.value = response["value"] as! String
    }
}
