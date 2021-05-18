//
//  BitcoinAddressValidator.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/16/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import DIKit
import RxSwift

final class BitcoinAddressValidator: BitcoinAddressValidatorAPI {
    
    private let bridge: BitcoinWalletBridgeAPI
    
    init(bridge: BitcoinWalletBridgeAPI = resolve()) {
        self.bridge = bridge
    }
    
    func validate(address: String) -> Completable {
        Completable.fromCallable { [weak self] in
            guard let self = self else {
                throw BitcoinReceiveAddressError.uninitialized
            }
            guard address.count >= 26 else {
                throw BitcoinReceiveAddressError.incompleteAddress
            }
            guard self.bridge.validateBitcoin(address: address) else {
                throw BitcoinReceiveAddressError.jsReturnedNil
            }
        }
    }
}
