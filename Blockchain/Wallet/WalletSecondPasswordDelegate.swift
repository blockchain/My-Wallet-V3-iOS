//
//  WalletSecondPasswordDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 6/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol WalletSecondPasswordDelegate: class {
    /// Method invoked when second password is required for JS function to complete.
    func getSecondPassword(success: WalletSuccessCallback)

    /// Method invoked when a password is required for bip38 private key decryption
    func getPrivateKeyPassword(success: WalletSuccessCallback)
}

protocol WalletSuccessCallback {
    func success(string: String)
}

extension JSValue: WalletSuccessCallback {
    func success(string: String) {
        self.call(withArguments: [string])
    }
}
