//
//  Strings.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
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

    /// Returns query arguments from a string in URL format
    var queryArgs: [String: String] {
        var queryArgs = [String: String]()
        let components = self.components(separatedBy: "&")
        components.forEach {
            let paramValueArray = $0.components(separatedBy: "=")

            if paramValueArray.count == 2,
                let param = paramValueArray[0].removingPercentEncoding,
                let value = paramValueArray[1].removingPercentEncoding {
                queryArgs[param] = value
            }
        }

        return queryArgs
    }
    // Returns a localized string from Localizable.strings
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: self, comment: "")
    }
}

extension NSString {
    @objc func isEmail() -> Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        var validated = false
        let range = NSRange(location: 0, length: (self as NSString).length)
        
        detector?.enumerateMatches(in: self as String, options: [], range: range) { result, _, _ in
            validated = result?.url?.scheme == "mailto"
        }
        return validated
    }
}
