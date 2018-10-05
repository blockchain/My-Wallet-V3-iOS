//
//  SocketMessage.swift
//  Blockchain
//
//  Created by kevinwu on 8/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TICKET: IOS-1318
// Move structs into separate files

enum SocketType: String {
    case unassigned
    case exchange
    case bitcoin
    case ether
    case bitcoinCash
}

struct SocketMessage {
    let type: SocketType
    let JSONMessage: Codable
}

protocol SocketMessageCodable: Codable {
    associatedtype JSONType: Codable
    static func tryToDecode(
        socketType: SocketType,
        data: Data,
        onSuccess: (SocketMessage) -> Void,
        onError: (String) -> Void
    )
}

extension SocketMessageCodable {
    static func tryToDecode(
        socketType: SocketType,
        data: Data,
        onSuccess: (SocketMessage) -> Void,
        onError: (String) -> Void
    ) {
        do {
            let decoded = try JSONType.decode(data: data)
            let socketMessage = SocketMessage(type: socketType, JSONMessage: decoded)
            onSuccess(socketMessage)
            return
        } catch {
            onError("Could not decode: \(error)")
        }
    }
}

// TODO: consider separate files when other socket types are added
// TODO: add tests when parameters are figured out

// MARK: - Subscribing
struct Subscription<SubscribeParams: Codable>: SocketMessageCodable {
    typealias JSONType = Subscription
    
    let channel: String
    let operation = "subscribe"
    let params: SubscribeParams

    private enum CodingKeys: CodingKey {
        case channel
        case operation
        case params
    }
}

struct AuthSubscribeParams: Codable {
    let type: String
    let token: String
}

struct ConversionSubscribeParams: Codable {
    let type: String
    let pair: String
    let fiatCurrency: String
    let fix: Fix
    let volume: String
}

struct AllCurrencyPairsUnsubscribeParams: Codable {
    let type = "allCurrencyPairs"
}

struct CurrencyPairsSubscribeParams: Codable {
    let type = "exchangeRates"
    let pairs: [String]
}

// MARK: - Unsubscribing

struct Unsubscription<UnsubscribeParams: Codable>: SocketMessageCodable {
    typealias JSONType = Unsubscription

    let channel: String
    let operation = "unsubscribe"
    let params: UnsubscribeParams
}

struct ConversionPairUnsubscribeParams: Codable {
    let type = "conversionPair"
    let pair: String
}

// MARK: - Received Messages

struct ExchangeRates: SocketMessageCodable {
    typealias JSONType = ExchangeRates

    let sequenceNumber: Int
    let channel: String
    let type: String
    let rates: [CurrencyPairRate]
}

extension ExchangeRates {
    func convert(balance: Decimal, fromCurrency: String, toCurrency: String) -> Decimal {
        if let matchingPair = pairRate(fromCurrency: fromCurrency, toCurrency: toCurrency) {
            return matchingPair.price * balance
        }
        return balance
    }

    func pairRate(fromCurrency: String, toCurrency: String) -> CurrencyPairRate? {
        return rates.first(where: { $0.pair == "\(fromCurrency)-\(toCurrency)" })
    }
}

struct HeartBeat: SocketMessageCodable {
    typealias JSONType = HeartBeat
    
    let sequenceNumber: Int
    let channel: String
    let type: String
    
    private enum CodingKeys: String, CodingKey {
        case sequenceNumber
        case channel
        case type
    }
}

struct Conversion: SocketMessageCodable {
    typealias JSONType = Conversion

    let sequenceNumber: Int
    let channel: String
    let type: String
    let quote: Quote

    private enum CodingKeys: CodingKey {
        case sequenceNumber
        case channel
        case type
        case quote
    }
}

extension Conversion: Equatable {
    static func == (lhs: Conversion, rhs: Conversion) -> Bool {
        return lhs.channel == rhs.channel &&
        lhs.type == rhs.type &&
        lhs.quote == rhs.quote
    }
}

extension Conversion {
    
    var baseFiatSymbol: String {
        return quote.currencyRatio.base.fiat.symbol
    }
    
    var baseFiatValue: String {
        return quote.currencyRatio.base.fiat.value
    }
    
    var baseCryptoSymbol: String {
        return quote.currencyRatio.base.crypto.symbol
    }
    
    var baseCryptoValue: String {
        return quote.currencyRatio.base.crypto.value
    }
}

/// `SocketError` is for any type of error that
/// is returned from the WS endpoint. 
struct SocketError: SocketMessageCodable, Error {
    typealias JSONType = SocketError
    
    enum SocketErrorType {
        
        case currencyRatioError
        case `default`
        
        init(rawValue: String) {
            switch rawValue {
            case "currencyRatioError":
                self = .currencyRatioError
            default:
                self = .default
            }
        }
    }
    
    
    let errorType: SocketErrorType
    let channel: String
    let description: String
    
    private enum CodingKeys: CodingKey {
        case type
        case channel
        case error
    }
    
    private enum ErrorKeys: CodingKey {
        case description
    }
    
    init(channel: String, description: String) {
        self.errorType = .default
        self.channel = channel
        self.description = description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeValue = try container.decode(String.self, forKey: .type)
        errorType = SocketErrorType(rawValue: typeValue)
        channel = try container.decode(String.self, forKey: .channel)
        let errorContainer = try container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        description = try errorContainer.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(errorType.rawValue, forKey: .type)
        try container.encode(channel, forKey: .channel)
        var errorContainer = container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        try errorContainer.encode(description, forKey: .description)
    }
}

extension SocketError {
    static let generic: SocketError = SocketError(channel: "unknown", description: "unknown")
}

extension SocketError.SocketErrorType {
    
    var rawValue: String {
        switch self {
        case .currencyRatioError:
            return "currencyRatioError"
        case .default:
            return "default"
        }
    }
}

// MARK: - Associated Models

struct CurrencyPairRate: Codable {
    let pair: String
    let price: Decimal

    enum CodingKeys: String, CodingKey {
        case pair
        case price
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pair = try container.decode(String.self, forKey: .pair)
        let priceString = try container.decode(String.self, forKey: .price)
        price = Decimal(string: priceString)!
    }
}

struct Quote: Codable {
    let time: String?
    let pair: String
    let fiatCurrency: String
    let fix: Fix
    let volume: String
    let currencyRatio: CurrencyRatio
}

extension Quote: Equatable {
    static func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.pair == rhs.pair &&
        lhs.fiatCurrency == rhs.fiatCurrency &&
        lhs.fix == rhs.fix &&
        lhs.volume == rhs.volume &&
        lhs.currencyRatio == rhs.currencyRatio
    }
}

struct CurrencyRatio: Codable {
    let base: FiatCrypto
    let counter: FiatCrypto
    let baseToFiatRate: String
    let baseToCounterRate: String
    let counterToBaseRate: String
    let counterToFiatRate: String
}

extension CurrencyRatio: Equatable {
    static func == (lhs: CurrencyRatio, rhs: CurrencyRatio) -> Bool {
        return lhs.base == rhs.base &&
        lhs.counter == rhs.counter &&
        lhs.baseToFiatRate == rhs.baseToFiatRate &&
        lhs.counterToBaseRate == rhs.counterToBaseRate &&
        lhs.counterToFiatRate == rhs.counterToFiatRate
    }
}

struct FiatCrypto: Codable {
    let fiat: SymbolValue
    let crypto: SymbolValue
}

extension FiatCrypto: Equatable {
    static func == (lhs: FiatCrypto, rhs: FiatCrypto) -> Bool {
        return lhs.fiat.symbol == rhs.fiat.symbol &&
            lhs.fiat.value == rhs.fiat.value &&
            lhs.crypto.value == rhs.crypto.value &&
            lhs.crypto.symbol == rhs.crypto.symbol
    }
}

struct SymbolValue: Codable {
    let symbol: String
    let value: String
}
