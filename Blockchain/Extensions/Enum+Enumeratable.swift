//
//  Enum+Enumerable.swift
//  Blockchain
//
//  Created by Maurice A. on 4/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol Enumeratable: Hashable {
    static var cases: [Self] { get }
}

extension Enumeratable {
    static var cases: [Self] {
        var cases: [Self] = []
        var index = 0
        for element: Self in AnyIterator({
            let item = withUnsafeBytes(of: &index) { $0.load(as: Self.self) }
            guard item.hashValue == index else { return nil }
            index += 1
            return item
        }) {
            cases.append(element)
        }
        return cases
    }
}
