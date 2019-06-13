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
    var walletLabel: String?
    var addressStatus = AddressStatus.empty
    var paxAmount: ERC20TokenValue<PaxToken>
    var fiatAmount: FiatValue
    var proposal: ERC20TransactionProposal<PaxToken>?
    var internalError: SendMoniesInternalError?
    
    var input: SendPaxInput {
        return SendPaxInput(
            addressStatus: addressStatus,
            paxAmount: paxAmount,
            fiatAmount: fiatAmount
        )
    }
    
    init(input: SendPaxInput = .empty) {
        self.addressStatus = input.addressStatus
        self.paxAmount = input.paxAmount
        self.fiatAmount = input.fiatAmount
    }
    
    mutating func updateWalletLabel(with tokenAccount: ERC20TokenAccount?) {
        if let tokenAccount = tokenAccount {
            walletLabel = tokenAccount.label
        }
    }
    
    var description: String {
        return "address: \(addressStatus) \n paxAmount: \(paxAmount.toDisplayString(includeSymbol: false, locale: Locale.current)) \n \(fiatAmount.toDisplayString()) \n internalError: \(String(describing: internalError))"
    }
}
