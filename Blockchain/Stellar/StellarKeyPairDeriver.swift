//
//  StellarKeyPairDeriver.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

typealias StellarWallet = stellarsdk.Wallet

/// Class for deriving a StellarKeyPair
class StellarKeyPairDeriver {

    /// Derives a `StellarKeyPair` given a mnemonic phrase.
    /// This action is deterministic (i.e. the same mnemonic + passphrase combination will create the
    /// same key pair).
    ///
    /// - Parameters:
    ///   - mnemonic: the mnemonic phrase used to derive the key pair for the new account
    ///   - passphrase: an optional passphrase for deriving the key pair
    ///   - account: the index of the wallet to create
    /// - Returns: the created StellarKeyPair
    func derive(mnemonic: String, passphrase: String? = nil, index: Int = 0) -> StellarKeyPair {
        //swiftlint:disable next force_try
        let keypair = try! StellarWallet.createKeyPair(mnemonic: mnemonic, passphrase: passphrase, index: index)
        return keypair.toStellarKeyPair()
    }
}

extension KeyPair {
    func toStellarKeyPair() -> StellarKeyPair {
        return StellarKeyPair(accountId: publicKey.accountId, secret: secretSeed)
    }
}
