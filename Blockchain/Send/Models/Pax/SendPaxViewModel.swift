//
//  SendPaxViewModel.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import ERC20Kit

struct SendPaxViewModel {
    var address: EthereumKit.EthereumAddress?
    var paxAmount: ERC20TokenValue<PaxToken>
    var fiatAmount: FiatValue
    var proposal: ERC20TransactionProposal<PaxToken>?
    var internalError: SendMoniesInternalError?
    
    var input: SendPaxInput {
        return SendPaxInput(
            address: address,
            paxAmount: paxAmount,
            fiatAmount: fiatAmount
        )
    }
    
    init(input: SendPaxInput = .empty) {
        self.address = input.address
        self.paxAmount = input.paxAmount
        self.fiatAmount = input.fiatAmount
    }
    
    var description: String {
        return "address: \(address?.rawValue ?? "") \n paxAmount: \(paxAmount.toDisplayString(includeSymbol: false, locale: Locale.current)) \n \(fiatAmount.toDisplayString()) \n internalError: \(String(describing: internalError))"
    }
}
