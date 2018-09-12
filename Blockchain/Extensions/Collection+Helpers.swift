//
//  Collection+Helpers.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Collection {

    /// Allows safe indexing into this collection. If the provided index is within
    /// bounds, the item will be returned, otherwise, nil.
    subscript (safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
