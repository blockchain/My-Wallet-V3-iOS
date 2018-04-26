//
//  AssetAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Blueprint for creating and validating asset addresses.
public protocol AssetAddress {
    /// String representation of the address.
    var address: String? { get }
    init(string: String)
    func isValid(_ address: String) -> Bool
}
