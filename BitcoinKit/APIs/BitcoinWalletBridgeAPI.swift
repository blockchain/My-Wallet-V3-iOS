//
//  BitcoinWalletBridgeAPI.swift
//  BitcoinKit
//
//  Created by kevinwu on 2/5/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public struct PayloadBitcoinHDWallet: Codable {
    
    public let seed_hex: String
    public let passphrase: String
    public let default_account_idx: Int
    public let accounts: [PayloadBitcoinWalletAccount]
}

public struct PayloadBitcoinWalletAccount: Codable {
    
    public struct Cache: Codable {
        public let receiveAccount: String
        public let changeAccount: String
    }
    
    public struct Label: Codable {
        public let index: Int
        public let label: String
    }
    
    public let label: String
    public let archived: Bool
    public let xpriv: String
    public let xpub: String
    public let address_labels: [Label]?
    public let cache: Cache
}

public protocol BitcoinWalletBridgeAPI: AnyObject {

    // MARK: - Wallet Account

    var defaultWallet: Single<BitcoinWalletAccount> { get }

    var wallets: Single<[BitcoinWalletAccount]> { get }
    
    var hdWallet: Single<PayloadBitcoinHDWallet> { get }

    func memo(for transactionHash: String) -> Single<String?>

    func updateMemo(for transactionHash: String, memo: String?) -> Completable

    func receiveAddress(forXPub xpub: String) -> Single<String>
    
    func walletIndex(for receiveAddress: String) -> Single<Int32>
    
    func validateBitcoin(address: String) -> Bool

    func update(accountIndex: Int, label: String) -> Completable
}

