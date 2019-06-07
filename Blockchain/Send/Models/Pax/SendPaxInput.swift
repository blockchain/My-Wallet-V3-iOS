//
//  SendPaxInput.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import ERC20Kit

struct SendPaxInput {
    var address: EthereumKit.EthereumAddress?
    var paxAmount: ERC20TokenValue<PaxToken>
    var fiatAmount: FiatValue
    
    init(address: EthereumKit.EthereumAddress? = nil,
         paxAmount: ERC20TokenValue<PaxToken>,
         fiatAmount: FiatValue) {
        self.address = address
        self.paxAmount = paxAmount
        self.fiatAmount = fiatAmount
    }
}

extension SendPaxInput {
    static let empty = SendPaxInput(
        paxAmount: .zero(),
        fiatAmount: .zero(currencyCode: BlockchainSettings.App.shared.fiatCurrencyCode)
    )
}
