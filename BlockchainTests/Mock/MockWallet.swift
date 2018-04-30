//
//  MockWallet.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 4/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class MockWallet: Wallet {

    /// When called, invokes the delegate's walletDidDecrypt and walletDidFinishLoad methods
    override func load(withGuid guid: String!, sharedKey: String!, password: String!) {
        self.delegate?.walletDidDecrypt!()
        self.delegate?.walletDidFinishLoad!()
    }
}
