//
//  Strings.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension String {

    /// Returns the first 5 characters of the SHA256 hash of this string
    var passwordPartHash: String? {
        guard let hashedString = NSString(string: self).sha256() else { return nil }
        let endIndex = hashedString.index(hashedString.startIndex, offsetBy: min(self.count, 5))
        return String(hashedString[..<endIndex])
    }

    /// Provided a URL query string such as "field1=value1&field2=value2", this computed property
    /// will return a dictionary in the format ["field1": "value1": "field2": "value2"]
    var urlQueryKeyPairDictionary: [String: String] {
        return [:]
    }
}
