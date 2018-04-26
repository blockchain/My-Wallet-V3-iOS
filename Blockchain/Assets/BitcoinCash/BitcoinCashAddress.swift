//
//  BitcoinCashAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct BitcoinCashAddress: AssetAddress {

    // MARK: - Properties

    public var address: String?

    // MARK: - Initialization

    public init(string: String) {
        self.address = nil
        if isValid(string) {
            address = string
        }
    }

    // MARK: Public Methods

    public func isValid(_ address: String) -> Bool {
        // TODO: implement validation logic
        return true
    }
}
