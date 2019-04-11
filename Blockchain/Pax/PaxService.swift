//
//  PaxService.swift
//  Blockchain
//
//  Created by Jack on 11/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
import EthereumKit


// https://api.staging.blockchain.info/v2/eth/data/account/0x4058a004DD718bABAb47e14dd0d744742E5B9903/token/0x8e870d67f660d95d5be530380d0ec0bd388289e1/wallet
// https://api.staging.blockchain.info/v2/eth/data/account/<ethereum_address>/token/<erc20_contract_address>/wallet


// TODO
// * DONE: Get ethereum address (from wallet)
// * DONE: Get pax balence from api (using ethereum address and hardcoded pax address)
// * Get pax exchange rate from api

// Later:
// * Think about PlatformKit APIs
// * create ERC20Kit
// * ...
// * Move to EthereumKit

protocol ERC20Contract {
    static var address: String { get }
}

struct Pax: ERC20Contract {
    static let address: String = ""
}

protocol PaxAccountAPI {
    var balance: Single<CryptoValue> { get }
}

public class PaxAccountService: PaxAccountAPI {
    
    public var balance: Single<CryptoValue> {
        return bridge.address
            .flatMap { [weak self] ethereumAddress in
                guard let self = self else {
                    return Single.error(TradeExecutionAPIError.generic) // TODO: Use proper error
                }
                return self.helper.fetchPaxBalance(ethereumAddress: ethereumAddress)
            }
            .debug()
    }
    
    private let bridge: EthereumWalletBridgeAPI
    
    private let helper: PaxEthereumServiceHelper
    
    init(with bridge: EthereumWalletBridgeAPI) {
        self.bridge = bridge
        self.helper = PaxEthereumServiceHelper(with: bridge)
    }
}

struct PaxTransafer: Decodable {
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

struct PaxAccount: Decodable {
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

class PaxEthereumServiceHelper {
    
    var ethereumAddress: Single<String> {
        return bridge.address
    }
    
    private var cachedAccount: PaxAccount?
    
    private let bridge: EthereumWalletBridgeAPI
    private let paxAccountClient: PaxAccountAPIClient
    
    init(with bridge: EthereumWalletBridgeAPI) {
        self.bridge = bridge
        self.paxAccountClient = PaxAccountAPIClient()
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

public final class PaxAccountAPIClient {
    
    static let contractAddress = "0x8e870d67f660d95d5be530380d0ec0bd388289e1"
    
    func fetchWalletAccount(ethereumAddress: String) -> Single<PaxAccount> {
        guard let baseURL = URL(string: apiUrl) else {
            return .error(TradeExecutionAPIError.generic)
        }
        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: [ "v2", "eth", "data", "account", ethereumAddress, "token", PaxAccountAPIClient.contractAddress, "wallet" ],
            queryParameters: nil
        ) else {
            return .error(TradeExecutionAPIError.generic)
        }
        return NetworkRequest.GET(url: endpoint, type: PaxAccount.self)
            .do(onError: { error in
                // TODO: this should be logged remotely
                Logger.shared.error(error)
            })
    }
    
    private let apiUrl: String
    
    init(apiUrl: String = BlockchainAPI.shared.apiUrl) {
        self.apiUrl = apiUrl
    }
}

//{
//    "accountHash": "0x4058a004dd718babab47e14dd0d744742e5b9903",
//    "tokenHash": "0x8e870d67f660d95d5be530380d0ec0bd388289e1",
//    "balance": "1000000000000000000",
//    "totalSent": "0",
//    "totalReceived": "1000000000000000000",
//    "decimals": 18,
//    "transferCount": "1",
//    "transfers": [{
//        "logIndex": "47",
//        "tokenHash": "0x8e870d67f660d95d5be530380d0ec0bd388289e1",
//        "from": "0x7fd882d87eca93443043876e391e8c640dde1585",
//        "to": "0x4058a004dd718babab47e14dd0d744742e5b9903",
//        "value": "1000000000000000000",
//        "decimals": 18,
//        "blockHash": "0xc334372acdc5d9aad37e47245584cb90ed2e4fb73380e7e092cd5a4feb823750",
//        "transactionHash": "0x9e883a801d04be5acbbd77902bac624724375d572c92746fbbf00c5a74e9c1a7",
//        "blockNumber": "7534562",
//        "idxFrom": "2",
//        "idxTo": "0",
//        "accountIdxFrom": "2",
//        "accountIdxTo": "0",
//        "timestamp": "1554821485"
//    }],
//    "page": "0",
//    "size": 50
//}


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
