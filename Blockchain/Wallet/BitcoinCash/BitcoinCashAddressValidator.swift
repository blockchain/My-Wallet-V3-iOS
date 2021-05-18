//
//  BitcoinCashAddressValidator.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/16/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinCashKit
import DIKit
import RxSwift

enum BitcoinCashWalletError: Error {
    case deallocated
    case incompleteAddress
    case invalidAddress
}

final class BitcoinCashAddressValidator: BitcoinCashAddressValidatorAPI {
    
    private let wallet: LegacyBitcoinCashWalletProtocol
    
    init(walletManager: WalletManager = resolve()) {
        self.wallet = walletManager.wallet
    }
    
    func validate(address: String) -> Completable {
        Completable.fromCallable { [weak self] in
            guard let self = self else {
                throw BitcoinCashWalletError.deallocated
            }
            guard address.count == 42 else {
                throw BitcoinCashWalletError.incompleteAddress
            }
            guard self.wallet.validateBitcoinCash(address: address) else {
                throw BitcoinCashWalletError.invalidAddress
            }
        }
    }
}
