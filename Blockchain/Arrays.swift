//
//  Arrays.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {

    /// Returns an array of unique values in the array
    var unique: [Element] {
        var uniques = [Element]()
        for value in self {
            if !uniques.contains(value) {
                uniques.append(value)
            }
        }
        return uniques
    }
}
