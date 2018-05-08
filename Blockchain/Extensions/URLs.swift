//
//  URLs.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension URL {

    /// Returns the query arguments of this URL as a key-value pair
    var queryArgs: [String: String] {
        guard let query = self.query else {
            return [:]
        }

        var queryArgs = [String: String]()
        let components = query.components(separatedBy: "&")
        components.forEach {
            let paramValueArray = $0.components(separatedBy: "=")

            if let param = paramValueArray[0].removingPercentEncoding,
                let value = paramValueArray[1].removingPercentEncoding,
                paramValueArray.count == 2 {
                queryArgs[param] = value
            }
        }

        return queryArgs
    }
}
