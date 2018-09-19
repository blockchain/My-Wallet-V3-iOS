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
            Logger.shared.debug("Decoded socket message of type \(JSONType.self)")
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

struct AllCurrencyPairsSubscribeParams: Codable {
    let type = "allCurrencyPairs"
}

// MARK: - Received Messages
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

extension Conversion {
    var baseToFiatDescription: String {
        let fiatSymbol = NumberFormatter.localCurrencyFormatter.currencySymbol ?? ""
        let base = "1" + " " + quote.currencyRatio.base.crypto.symbol
        let fiat = fiatSymbol + quote.currencyRatio.baseToFiatRate
        return base + " = " + fiat
    }
    
    var baseToCounterDescription: String {
        let base = "1" + " " + quote.currencyRatio.base.crypto.symbol
        let counterSymbol = quote.currencyRatio.counter.crypto.symbol
        let counter = quote.currencyRatio.baseToCounterRate + " " + counterSymbol
        return base + " = " + counter
    }
    
    var counterToFiatDescription: String {
        let counterSymbol = quote.currencyRatio.counter.crypto.symbol
        let fiatSymbol = NumberFormatter.localCurrencyFormatter.currencySymbol ?? ""
        let counter = "1" + " " + counterSymbol
        let fiat = fiatSymbol + quote.currencyRatio.counterToFiatRate
        return counter + " = " + fiat
    }
}

// MARK - Associated Models

struct Quote: Codable {
    let time: String?
    let pair: String
    let fiatCurrency: String
    let fix: Fix
    let volume: String
    let currencyRatio: CurrencyRatio
}

struct CurrencyRatio: Codable {
    let base: FiatCrypto
    let counter: FiatCrypto
    let baseToFiatRate: String
    let baseToCounterRate: String
    let counterToBaseRate: String
    let counterToFiatRate: String
}

struct FiatCrypto: Codable {
    let fiat: SymbolValue
    let crypto: SymbolValue
}

struct SymbolValue: Codable {
    let symbol: String
    let value: String
}
