//
//  BitcoinWalletBridgeMock.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BitcoinKit
import Foundation
import RxSwift

class BitcoinWalletBridgeMock: BitcoinWalletBridgeAPI {

    enum MockError: Error {
        case error
    }
    
    func walletIndex(for receiveAddress: String) -> Single<Int32> {
        .never()
    }

    var receiveAddressValue: Single<String> = .error(MockError.error)
    func receiveAddress(forXPub xpub: String) -> Single<String> {
        receiveAddressValue
    }

    var memoValue: Single<String?> = .just(nil)
    func memo(for transactionHash: String) -> Single<String?> {
        memoValue
    }

    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }
    
    func validateBitcoin(address: String) -> Bool {
        true
    }

    var hdWalletValue: Single<PayloadBitcoinHDWallet> = Single.error(MockError.error)
    var hdWallet: Single<PayloadBitcoinHDWallet> {
        hdWalletValue
    }

    var defaultWalletValue: Single<BitcoinWalletAccount> = Single.error(MockError.error)
    var defaultWallet: Single<BitcoinWalletAccount> {
        defaultWalletValue
    }

    var walletsValue: Single<[BitcoinWalletAccount]> = Single.just([])
    var wallets: Single<[BitcoinWalletAccount]> {
        walletsValue
    }
}
