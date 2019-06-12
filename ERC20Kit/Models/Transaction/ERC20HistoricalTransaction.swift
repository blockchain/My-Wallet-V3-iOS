//
//  ERC20HistoricalTransaction.swift
//  ERC20Kit
//
//  Created by AlexM on 5/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import EthereumKit
import BigInt
import RxSwift

public struct ERC20AccountTransactionsResponse<Token: ERC20Token>: Decodable, Tokenized {
    
    public let fromAddress: EthereumAssetAddress
    public let transactions: [ERC20HistoricalTransaction<Token>]
    public let pageSize: Int
    public let currentPage: Int
    
    public var token: String {
        return String(currentPage)
    }
    
    // MARK: Decodable
    
    enum CodingKeys: String, CodingKey {
        case transactions = "transfers"
        case fromAddress = "accountHash"
        case page
        case size
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let from = try values.decode(String.self, forKey: .fromAddress)
        fromAddress = EthereumAssetAddress(publicKey: from)
        transactions = try values.decode([ERC20HistoricalTransaction<Token>].self, forKey: .transactions)
        let page = try values.decode(String.self, forKey: .page)
        currentPage = Int(page) ?? 0
        pageSize = try values.decode(Int.self, forKey: .size)
    }
}

public struct ERC20HistoricalTransaction<Token: ERC20Token>: Decodable, Hashable, HistoricalTransaction, Tokenized {
    
    public typealias Address = EthereumAssetAddress
    
    /// There's not much point to `token` in this case since
    /// for ERC20 paging we use the `wallet.transactions.count` to determine
    /// if we need to fetch additional transactions.
    public var token: String {
        return transactionHash
    }
    
    public var identifier: String {
        return transactionHash
    }
    public var fromAddress: EthereumAssetAddress
    public var toAddress: EthereumAssetAddress
    public var direction: Direction
    public var amount: String
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var historicalFiatValue: FiatValue?
    public var memo: String?
    public var cryptoAmount: CryptoValue {
        return CryptoValue.createFromMinorValue(BigInt(stringLiteral: amount), assetType: Token.assetType)
    }
    
    public init(
        fromAddress: Address,
        toAddress: Address,
        direction: Direction,
        amount: String,
        transactionHash: String,
        createdAt: Date,
        fee: CryptoValue? = nil,
        memo: String? = nil
    ) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.memo = memo
    }
    
    public func make(from direction: Direction, fee: CryptoValue? = nil, memo: String? = nil) -> ERC20HistoricalTransaction<Token> {
        return ERC20HistoricalTransaction<Token>(
            fromAddress: fromAddress,
            toAddress: toAddress,
            direction: direction,
            amount: amount,
            transactionHash: transactionHash,
            createdAt: createdAt,
            fee: fee,
            memo: memo
        )
    }
    
    // MARK: Decodable
    
    enum CodingKeys: String, CodingKey {
        case transactionHash
        case timestamp
        case from
        case to
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let from = try values.decode(String.self, forKey: .from)
        let to = try values.decode(String.self, forKey: .to)
        let timestampString = try values.decode(String.self, forKey: .timestamp)
        transactionHash = try values.decode(String.self, forKey: .transactionHash)
        amount = try values.decode(String.self, forKey: .value)
        fromAddress = EthereumAssetAddress(publicKey: from)
        toAddress = EthereumAssetAddress(publicKey: to)
        if let timeSinceEpoch = Double(timestampString) {
            createdAt = Date(timeIntervalSince1970: timeSinceEpoch)
        } else {
            createdAt = Date()
        }
        
        // ⚠️ NOTE: The direction is populated when you fetch transactions
        // and the user's ETH address is passed in. That's the only way to know
        // whether or not it is a debit or credit.
        // Fees are only known when we fetch the details of the transaction.
        // the `historicalFiatValue` is only know when we fetch the details
        // of the transaction.
        direction = .debit
        fee = nil
        memo = nil
    }
    
    // MARK: Public
    
    public func fetchTransactionDetails(currencyCode: String = "USD") -> Single<ERC20HistoricalTransaction<Token>> {
        let zip = Single.zip(transactionDetails, historicalFiatPrice(with: currencyCode))
        return zip.flatMap {
            var output = self.make(from: self.direction, fee: $0.0.fee, memo: nil)
            output.historicalFiatValue = self.cryptoAmount.convertToFiatValue(exchangeRate: $0.1.priceInFiat)
            return Single.just(output)
        }
    }
    
    // MARK: Private
    
    private var transactionDetails: Single<ERC20TransactionDetails<Token>> {
        guard let baseURL = URL(string: BlockchainAPI.shared.apiUrl) else {
            return Single.error(NetworkError.generic(message: "Invalid URL"))
        }
        let components = ["v2", "eth", "data", "transaction", transactionHash]
        guard let endpoint = URL.endpoint(baseURL, pathComponents: components, queryParameters: nil) else {
            return Single.error(NetworkError.generic(message: "Invalid URL"))
        }
        return NetworkRequest.GET(url: endpoint, type: ERC20TransactionDetails<Token>.self)
    }
    
    // Provides price index (exchange rate) between supported cryptocurrency and fiat currency.
    // This is how you populate the `historicalFiatValue`.
    public func historicalFiatPrice(with currencyCode: String) -> Single<PriceInFiatValue> {
        guard let baseUrl = URL(string: BlockchainAPI.shared.servicePriceUrl) else {
            return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        let parameters = ["base": Token.assetType.symbol,
                          "quote": currencyCode,
                          "start": "\(createdAt.timeIntervalSince1970)"]
        
        guard let url = URL.endpoint(
            baseUrl,
            pathComponents: ["index"],
            queryParameters: parameters
            ) else {
                return Single.error(NetworkError.generic(message: "URL is invalid."))
        }
        return NetworkRequest.GET(url: url, type: PriceInFiat.self).map {
            $0.toPriceInFiatValue(currencyCode: currencyCode)
        }
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fromAddress)
        hasher.combine(toAddress)
        hasher.combine(direction.rawValue)
        hasher.combine(amount)
        hasher.combine(transactionHash)
        hasher.combine(createdAt)
    }
    
    // MARK: Private
    
    struct ERC20TransactionDetails<T: ERC20Token>: Decodable {
        let gasPrice: BigInt
        let gasLimit: BigInt
        let gasUsed: BigInt
        let success: Bool
        let data: Data?
        
        // MARK: Decodable
        
        enum CodingKeys: String, CodingKey {
            case gasPrice
            case gasLimit
            case gasUsed
            case success
            case data
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let limit = try values.decode(String.self, forKey: .gasLimit)
            let price = try values.decode(String.self, forKey: .gasPrice)
            let used = try values.decode(String.self, forKey: .gasUsed)
            let dataValue = try values.decode(String.self, forKey: .data)
            success = try values.decode(Bool.self, forKey: .success)
            data = dataValue.data(using: .utf8)
            gasPrice = BigInt(stringLiteral: price)
            gasLimit = BigInt(stringLiteral: limit)
            gasUsed = BigInt(stringLiteral: used)
        }
    }
}

private extension ERC20HistoricalTransaction.ERC20TransactionDetails {
    var fee: CryptoValue {
        let amount = gasUsed * gasPrice
        return CryptoValue.createFromMinorValue(amount, assetType: .ethereum)
    }
}
