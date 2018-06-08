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

        return query.queryArgs
    }
}
