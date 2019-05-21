//
//  EthereumTransactionBuilder.swift
//  EthereumKit
//
//  Created by Jack on 26/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import web3swift
import BigInt
import PlatformKit

public enum EthereumTransactionBuilderError: Error {
    case insufficientFunds
    case invalidAmount
}

public protocol EthereumTransactionBuilderAPI {
    func build(transaction: EthereumTransactionCandidate
        ) -> NewResult<EthereumTransactionCandidateCosted, EthereumTransactionBuilderError>
}

public class EthereumTransactionBuilder: EthereumTransactionBuilderAPI {
    public static let shared = EthereumTransactionBuilder()
    
    public func build(transaction: EthereumTransactionCandidate
        ) -> NewResult<EthereumTransactionCandidateCosted, EthereumTransactionBuilderError> {
        print("transaction.value: \(transaction.value)")
        
        let value = transaction.value
        let gasPrice = transaction.gasPrice
        let gasLimit = transaction.gasLimit
        let data = transaction.data ?? Data()

        let fee = gasPrice * gasLimit
        
        print("gasPrice: \(gasPrice)")
        print("gasLimit: \(gasLimit)")
        print("     fee: \(fee)")
        print("\n")
        
        let to: web3swift.Address = transaction.to.web3swiftAddress
        
        var tx: web3swift.EthereumTransaction = web3swift.EthereumTransaction(
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: value,
            data: data
        )
        tx.UNSAFE_setChainID(NetworkId.mainnet)
        
        print("tx.gasPrice: \(tx.gasPrice)")
        print("tx.gasLimit: \(tx.gasLimit)")
        print("   tx.value: \(tx.value)")
        print("   tx.value.string(unitDecimals: 18): \(tx.value.string(unitDecimals: 18))")
        
        // swiftlint:disable force_try
        return .success(try! EthereumTransactionCandidateCosted(transaction: tx))
        // swiftlint:enable force_try
    }
}
