//
//  BitcoinCashAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct BitcoinCashAddress: AssetAddress {

    // MARK: - Properties

    let address: String?

    // MARK: - Initialization

    init(string: String) {
        self.address = BitcoinCashAddress.isValid(string) ? string : nil
    }

    // MARK: Public Methods

    static func isValid(_ address: String) -> Bool {
        // TODO: implement validation logic
        return true
    }
}
