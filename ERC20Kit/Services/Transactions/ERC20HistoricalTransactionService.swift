//
//  ERC20HistoricalTransactionService.swift
//  ERC20Kit
//
//  Created by AlexM on 5/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import RxSwift

public protocol ERC20WalletTransctionsBridgeAPI: class {
    associatedtype Token
    var transactions: Single<[EthereumTransaction]> { get }
}

public class AnyERC20HistoricalTransactionService<Token: ERC20Token>: TokenizedHistoricalTransactionAPI {
    public typealias Model = ERC20HistoricalTransaction<Token>
    public typealias Bridge = ERC20WalletTransctionsBridgeAPI
    public typealias PageModel = PageResult<Model>
    
    private let bridge: EthereumWalletBridgeAPI
    
    private var ethereumAddress: Single<String> {
        return bridge.address
    }
    
    public init(bridge: EthereumWalletBridgeAPI) {
        self.bridge = bridge
    }
    
    public func fetchTransactions(token: String?, size: Int) -> Single<PageModel> {
        let page = token ?? "0"
        return ethereumAddress.flatMap { address in
            return self.fetchTransactionResponse(from: page).flatMap {
                let result: [ERC20HistoricalTransaction<Token>] = $0.transactions.map { transaction in
                    let direction: Direction = transaction.fromAddress.publicKey == address.lowercased() ? .debit : .credit
                    return transaction.make(from: direction)
                }
                let output = PageModel(
                    hasNextPage: result.count >= size,
                    items: result
                )
                return Single.just(output)
            }
        }
    }
    
    public func fetchTransactions() -> Single<[ERC20HistoricalTransaction<Token>]> {
        return ethereumAddress.flatMap {
            return self.fetchTransactions(from: $0)
        }
    }
    
    private func fetchTransactions(from address: String) -> Single<[ERC20HistoricalTransaction<Token>]> {
        return fetchTransactionResponse().flatMap {
            let result: [ERC20HistoricalTransaction<Token>] = $0.transactions.map {
                let direction: Direction = $0.fromAddress.publicKey == address ? .debit : .credit
                return $0.make(from: direction)
            }
            return Single.just(result)
        }
    }
    
    private func fetchTransactionResponse(from page: String = "0") -> Single<ERC20AccountTransactionsResponse<Token>> {
        return ethereumAddress.flatMap { address -> Single<ERC20AccountTransactionsResponse<Token>> in
            guard let baseURL = URL(string: BlockchainAPI.shared.apiUrl) else {
                return Single.error(NetworkError.generic(message: "Invalid URL"))
            }
            let params = ["page": String(page)]
            let components = ["v2", "eth", "data", "account", address, "token", Token.contractAddress.ethereumAddress.rawValue, "wallet"]
            guard let endpoint = URL.endpoint(baseURL, pathComponents: components, queryParameters: params) else {
                return Single.error(NetworkError.generic(message: "Invalid URL"))
            }
            
            return NetworkRequest.GET(url: endpoint, type: ERC20AccountTransactionsResponse<Token>.self)
        }
    }
}
