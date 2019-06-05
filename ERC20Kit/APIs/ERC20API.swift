//
//  ERC20API.swift
//  ERC20Kit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import RxSwift
import PlatformKit
import EthereumKit

public struct ERC20TransactionProposal<Token: ERC20Token> {
    public let from: EthereumKit.EthereumAddress
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let value: ERC20TokenValue<Token>
    
    public init(from: EthereumKit.EthereumAddress,
                gasPrice: BigUInt,
                gasLimit: BigUInt,
                value: ERC20TokenValue<Token>) {
        self.from = from
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
    }
}

extension ERC20TransactionProposal: Equatable {
    public static func == (lhs: ERC20TransactionProposal, rhs: ERC20TransactionProposal) -> Bool {
        return lhs.from == rhs.from &&
            lhs.gasLimit == rhs.gasLimit
            && lhs.gasPrice == rhs.gasPrice
            && lhs.value.value == rhs.value.value
    }
}

public protocol ERC20API {
    associatedtype Token: ERC20Token
    
    func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate>
    
    func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>, fee: EthereumTransactionFee) -> Single<EthereumTransactionCandidate>
    
    func transfer(proposal: ERC20TransactionProposal<Token>, to address: EthereumKit.EthereumAddress) -> Single<EthereumTransactionCandidate>
}

public protocol ERC20TransactionEvaluationAPI {
    associatedtype Token: ERC20Token
    
    func evaluate(amount cryptoValue: ERC20TokenValue<Token>) -> Single<ERC20TransactionProposal<Token>>
    
    func evaluate(amount cryptoValue: ERC20TokenValue<Token>, fee: EthereumTransactionFee) -> Single<ERC20TransactionProposal<Token>>
}

public protocol ERC20TransactionMemoAPI {
    associatedtype Token: ERC20Token
    
    func memo(for transactionHash: String) -> Single<String?>
    func save(transactionMemo: String, for transactionHash: String) -> Completable
}
