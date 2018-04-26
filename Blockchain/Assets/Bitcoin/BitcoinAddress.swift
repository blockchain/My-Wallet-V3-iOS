//
//  BitcoinAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct BitcoinAddress: AssetAddress {

    // MARK: - Properties

    public let address: String?

    // MARK: - Initialization

    public init(string: String) {
        self.address = BitcoinAddress.isValid(string) ? string : nil
    }

    // MARK: Public Methods

    public static func isValid(_ address: String) -> Bool {
        // TODO: implement validation logic
        return true
    }
}
