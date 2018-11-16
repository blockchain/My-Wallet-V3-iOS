//
//  StellarKeyPairDeriver.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import stellarsdk

public class StellarKeyPairDeriver: KeyPairDeriver {
    public typealias StellarWallet = stellarsdk.Wallet
    public typealias Pair = StellarKeyPair
    
    public func derive(mnemonic: String, passphrase: String?, index: Int) -> Pair {
        //swiftlint:disable next force_try
        let keypair = try! StellarWallet.createKeyPair(mnemonic: mnemonic, passphrase: passphrase, index: index)
        return keypair.toStellarKeyPair()
    }
}

private extension stellarsdk.KeyPair {
    func toStellarKeyPair() -> StellarKeyPair {
        return StellarKeyPair(accountID: publicKey.accountId, secret: secretSeed)
    }
}
