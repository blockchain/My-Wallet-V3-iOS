//
//  SocketMessage.swift
//  Blockchain
//
//  Created by kevinwu on 8/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

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
            onError("Could not decode")
        }
    }
}

// TODO: consider separate files when other socket types are added
// TODO: add tests when parameters are figured out

// MARK: - Subscribing
struct Subscription<SubscribeParams: Codable>: SocketMessageCodable {
    typealias JSONType = Subscription
    
    let channel: String
    let operation: String
    let params: SubscribeParams

    private enum CodingKeys: CodingKey {
        case channel
        case operation
        case params
    }
}

struct AuthSubscribeParams: Codable {
    let type, token: String
}

struct ConversionSubscribeParams: Codable {
    let type: String
    let pair: String
    let fiatCurrency: String
    let fix: Fix
    let volume: Decimal
}

// MARK: - Received Messages
struct HeartBeat: SocketMessageCodable {
    typealias JSONType = HeartBeat
    
    let sequenceNumber: Int
    let channel, type: String
    
    private enum CodingKeys: String, CodingKey {
        case sequenceNumber
        case channel
        case type
    }
}

struct Conversion: SocketMessageCodable {
    typealias JSONType = Conversion

    let sequenceNumber: Int
    let channel, type, pair, fiatCurrency: String
    let fix: Fix
    let volume: Decimal
    let currencyRatio: CurrencyRatio

    private enum CodingKeys: CodingKey {
        case sequenceNumber
        case channel
        case type
        case pair
        case fiatCurrency
        case fix
        case volume
        case currencyRatio
    }
}

struct CurrencyRatio: Codable {
    let base: FiatCrypto
    let counter: FiatCrypto
    let baseToFiatRate: Decimal
    let baseToCounterRate: Decimal
    let counterToBaseRate: Decimal
    let counterToFiatRate: Decimal
}

struct FiatCrypto: Codable {
    let fiat: SymbolValue
    let crypto: SymbolValue
}

struct SymbolValue: Codable {
    let symbol: String
    let value: Decimal
}

struct Rate: SocketMessageCodable {
    typealias JSONType = Rate

    let parameterOne: String

    private enum CodingKeys: String, CodingKey {
        case parameterOne
    }
}
