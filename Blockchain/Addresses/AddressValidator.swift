//
//  AddressValidator.swift
//  Blockchain
//
//  Created by Maurice A. on 5/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc
public final class AddressValidator: NSObject {

    // MARK: - Properties

    private let context: JSContext

    // MARK: - Initialization

    @objc init(context: JSContext) {
        self.context = context
    }

    // MARK: - Bitcoin Address Validation

    @objc
    func validate(bitcoinAddress address: BitcoinAddress) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context.evaluateScript("Helpers.isBitcoinAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }

    // MARK: - Bitcoin Cash Address Validation

    @objc
    func validate(bitcoinCashAddress address: BitcoinCashAddress) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context.evaluateScript("MyWalletPhone.bch.isValidAddress(\"\(escapedString)\");") else {
            let possibleBTCAddress = BitcoinAddress(string: address.description)
            return validate(bitcoinAddress: possibleBTCAddress)
        }
        return result.toBool()
    }

    // MARK: - Ethereum Address Validation

    @objc
    func validate(ethereumAddress address: EthereumAddress) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context.evaluateScript("MyWalletPhone.isEthAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }
}
