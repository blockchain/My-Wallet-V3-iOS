//
//  PaxToken.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import EthereumKit

public struct PaxToken: Token {
    
    
    
}


protocol ERC20Contract {
    static var address: String { get }
}

public struct Pax: ERC20Contract {
    static let address: String = ""
}

public protocol PaxAccountAPI {
    var balance: Single<CryptoValue> { get }
}

public enum ERC20Error: Error {
    case unknown
}

public class PaxAccountService: PaxAccountAPI {
    
    public var balance: Single<CryptoValue> {
        return bridge.address
            .flatMap { [weak self] ethereumAddress in
                guard let self = self else {
                    return Single.error(ERC20Error.unknown) // TODO: Use proper error
                }
                return self.helper.fetchPaxBalance(ethereumAddress: ethereumAddress)
            }
            .debug()
    }
    
    private let bridge: EthereumWalletBridgeAPI
    
    private let helper: PaxEthereumServiceHelper
    
    public init(with bridge: EthereumWalletBridgeAPI, paxAccountClient: PaxAccountAPIClientAPI) {
        self.bridge = bridge
        self.helper = PaxEthereumServiceHelper(
            with: bridge,
            paxAccountClient: paxAccountClient
        )
    }
}

public struct PaxTransafer: Decodable {
    let logIndex: String
    let tokenHash: String
    let accountFrom: String
    let accountTo: String
    let value: String
    let decimals: Int
    let blockHash: String
    let transactionHash: String
    let blockNumber: String
    let idxFrom: String
    let idxTo: String
    let accountIdxFrom: String
    let accountIdxTo: String
    
    //        "logIndex": "20",
    //        "tokenHash": "0x8e870d67f660d95d5be530380d0ec0bd388289e1",
    //        "accountFrom": "0xaee601e499b57557bf68d566488a5028316c1b9b",
    //        "accountTo": "0xcc312b1abacf676e2daf6b2672acf552ce29a25a",
    //        "value": "500000000000000000",
    //        "decimals": 18,
    //        "blockHash": "0x913752bc0a6118eaa6a938bc208b3b6174da78ebcf35ac733bdcc48fa53b9486",
    //        "transactionHash": "0xc468ab3a8b0c10a97f8bd6b0b4bb248481daaae28f68253f59d7d2d42042b60e",
    //        "blockNumber": "7534751",
    //        "idxFrom": "1",
    //        "idxTo": "0",
    //        "accountIdxFrom": "6",
    //        "accountIdxTo": "0"
}

public struct PaxAccount: Decodable {
    let accountHash: String
    let tokenHash: String
    let balance: String
    let totalSent: String
    let totalReceived: String
    let decimals: Int
    let transferCount: String
    let transfers: [PaxTransafer]
    let page: String
    let size: Int
    
    //{
    //    "accountHash": "0xcc312b1abacf676e2daf6b2672acf552ce29a25a",
    //    "tokenHash": "0x8e870d67f660d95d5be530380d0ec0bd388289e1",
    //    "balance": "500000000000000000",
    //    "totalSent": "0",
    //    "totalReceived": "500000000000000000",
    //    "decimals": 18,
    //    "transferCount": "1",
    //    "transfers": [{
    //        "logIndex": "20",
    //        "tokenHash": "0x8e870d67f660d95d5be530380d0ec0bd388289e1",
    //        "accountFrom": "0xaee601e499b57557bf68d566488a5028316c1b9b",
    //        "accountTo": "0xcc312b1abacf676e2daf6b2672acf552ce29a25a",
    //        "value": "500000000000000000",
    //        "decimals": 18,
    //        "blockHash": "0x913752bc0a6118eaa6a938bc208b3b6174da78ebcf35ac733bdcc48fa53b9486",
    //        "transactionHash": "0xc468ab3a8b0c10a97f8bd6b0b4bb248481daaae28f68253f59d7d2d42042b60e",
    //        "blockNumber": "7534751",
    //        "idxFrom": "1",
    //        "idxTo": "0",
    //        "accountIdxFrom": "6",
    //        "accountIdxTo": "0"
    //    }],
    //    "page": "0",
    //    "size": 50
    //}
    
}

public class PaxEthereumServiceHelper {
    
    var ethereumAddress: Single<String> {
        return bridge.address
    }
    
    private var cachedAccount: PaxAccount?
    
    private let bridge: EthereumWalletBridgeAPI
    private let paxAccountClient: PaxAccountAPIClientAPI
    
    init(with bridge: EthereumWalletBridgeAPI, paxAccountClient: PaxAccountAPIClientAPI) {
        self.bridge = bridge
        self.paxAccountClient = paxAccountClient
    }
    
    func fetchPaxBalance(ethereumAddress: String) -> Single<CryptoValue> {
        if let cachedAccount = cachedAccount {
            return Single.just(CryptoValue.paxFromMajor(string: cachedAccount.balance)!) // TODO: don't cache this
        }
        return self.paxAccountClient.fetchWalletAccount(ethereumAddress: ethereumAddress)
            .map { account in
                return CryptoValue.paxFromMajor(string: account.balance)!
        }
    }
    
}

// https://api.staging.blockchain.info/v2/eth/data/account/<ethereum_address>/token/<erc20_contract_address>/wallet

public protocol PaxAccountAPIClientAPI {
    func fetchWalletAccount(ethereumAddress: String) -> Single<PaxAccount>
}
