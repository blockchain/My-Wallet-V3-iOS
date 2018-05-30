//
//  AddressValidator.swift
//  Blockchain
//
//  Created by Maurice A. on 5/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TODO: use associatedtype in protocol once there are no more objc dependents

@objc
public final class AddressValidator: NSObject {

    // MARK: - Properties

    private var context: JSContext?

    static let shared = AddressValidator()

    // MARK: - Initialization

    private init?(context: JSContext? = WalletManager.shared.wallet.context) {
        guard let JSContext = context else { return nil }
        self.context = JSContext
    }

    // MARK: - Bitcoin Address Validation

    func validate(bitcoinAddress address: BitcoinAddress) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context?.evaluateScript("Helpers.isBitcoinAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }

    // MARK: - Bitcoin Cash Address Validation

    func validate(bitcoinCashAddress address: BitcoinCashAddress) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context?.evaluateScript("MyWalletPhone.bch.isValidAddress(\"\(escapedString)\");") else {
            let possibleBTCAddress = BitcoinAddress(string: address.description)
            return validate(bitcoinAddress: possibleBTCAddress)
        }
        return result.toBool()
    }

    // MARK: - Ethereum Address Validation

    func validate(ethereumAddress address: EthereumAddress) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context?.evaluateScript("MyWalletPhone.isEthAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }
}
