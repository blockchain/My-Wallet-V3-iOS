//
//  WalletCryptoService.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class WalletCryptoService {
    static let shared = WalletCryptoService()

    /// Generates a mnemonic code (BIP 39: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
    /// This mnemonic code can then be converted to a binary seed which can be later used to generate
    /// an HD wallet.
    ///
    /// - Returns: a Single returning the mnemonic code.
    func generateMnemonic() -> Single<String> {
        // TODO: integrate BitcoinKit
        return Single.just("")
    }
}
