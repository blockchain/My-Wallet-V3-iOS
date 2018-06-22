//
//  Enum+RawValued.swift
//  Blockchain
//
//  Created by Maurice A. on 4/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for an enum that is also a `RawValue`.
/// Note: do not use this protocol on enums that are also Ints
/// as there is a known buffer overflow issue with release builds
/// See: https://github.com/blockchain/My-Wallet-V3-iOS/pull/264
protocol RawValued: Hashable, RawRepresentable {
    static var rawValues: [RawValue] { get }
}

extension RawValued {
    static var rawValues: [RawValue] {
        var rawValues: [RawValue] = []
        var index = 0
        for element: Self in AnyIterator({
            let item = withUnsafeBytes(of: &index) { $0.load(as: Self.self) }
            guard item.hashValue == index else { return nil }
            index += 1
            return item
        }) {
            rawValues.append(element.rawValue)
        }
        return rawValues
    }
}
