//
//  BitcoinCashWalletBridgeAPI.swift
//  BitcoinCashKit
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BitcoinCashWalletBridgeAPI {
    var defaultWallet: Single<BitcoinCashWalletAccount> { get }
    var wallets: Single<[BitcoinCashWalletAccount]> { get }

    func receiveAddress(forXPub xpub: String) -> Single<String>
    func update(accountIndex: Int, label: String) -> Completable 
}
