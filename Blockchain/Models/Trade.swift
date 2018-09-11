//
//  Trade.swift
//  Blockchain
//
//  Created by kevinwu on 5/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Model for buy-sell trades.
// TODO: integrate with Exchange trades.

extension Trade {
    static func demo() -> Trade {
        let trade = Trade(pair: TradingPair(from: .bitcoin, to: .ethereum)!)
        return trade
    }
}

struct Trade: Decodable {
    
    let identifier: String
    let created: Date
    let updated: Date
    let pair: TradingPair
    let side: Side
    let quantity: Decimal
    let currency: AssetType
    let refundAddress: String
    let price: Decimal
    let depositAddress: String
    let depositQuantity: Decimal
    let withdrawalAddress: String
    let withdrawalQuantity: Decimal
    let depositHash: String
    let withdrawalHash: String

    private struct Keys {
        static let created = "createdAt"
        static let receiveAddress = "receiveAddress"
        static let tradeHash = "txHash"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case pair
        case side
        case quantity
        case currency
        case refundAddress
        case price
        case depositAddress
        case depositQuantity
        case withdrawlAddress
        case withdrawlQuantity
        case depositTxHash
        case withdrawalTxHash
        case state
    }
    
    init(pair: TradingPair) {
        self.identifier = ""
        self.created = Date()
        self.updated = Date()
        self.side = .buy
        self.quantity = 0.0012
        self.currency = .bitcoin
        self.refundAddress = "123"
        self.price = 0.345
        self.depositAddress = "321"
        self.depositQuantity = 0.0012
        self.withdrawalAddress = "123"
        self.withdrawalQuantity = 0.0012
        self.depositHash = "abcdefg"
        self.withdrawalHash = "qrstuv"
        self.pair = pair
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        identifier = try values.decode(String.self, forKey: .id)
        
        let createdDate = try values.decode(String.self, forKey: .createdAt)
        let updatedDate = try values.decode(String.self, forKey: .updatedAt)
        let trading = try values.decode(String.self, forKey: .pair)
        let sideValue = try values.decode(String.self, forKey: .side)
        let assetValue = try values.decode(String.self, forKey: .currency)
        
        created = DateFormatter.sessionDateFormat.date(from: createdDate) ?? Date()
        updated = DateFormatter.sessionDateFormat.date(from: updatedDate) ?? Date()
        
        if let value = TradingPair(string: trading) {
            pair = value
        } else {
            throw DecodingError.valueNotFound(
                TradingPair.self,
                .init(codingPath: [CodingKeys.pair], debugDescription: "")
            )
        }
        if let value = Side(rawValue: sideValue) {
            side = value
        } else {
            throw DecodingError.valueNotFound(
                Side.self,
                .init(codingPath: [CodingKeys.side], debugDescription: "")
            )
        }
        if let value = AssetType(stringValue: assetValue) {
            currency = value
        } else {
            throw DecodingError.valueNotFound(
                AssetType.self,
                .init(codingPath: [CodingKeys.currency], debugDescription: "")
            )
        }
        
        quantity = try values.decode(String.self, forKey: .quantity).toDecimal()
        refundAddress = try values.decode(String.self, forKey: .refundAddress)
        price = try values.decode(String.self, forKey: .price).toDecimal()
        depositAddress = try values.decode(String.self, forKey: .depositAddress)
        depositQuantity = try values.decode(String.self, forKey: .depositQuantity).toDecimal()
        withdrawalAddress = try values.decode(String.self, forKey: .withdrawlAddress)
        withdrawalQuantity = try values.decode(String.self, forKey: .withdrawlQuantity).toDecimal()
        depositHash = try values.decode(String.self, forKey: .depositTxHash)
        withdrawalHash = try values.decode(String.self, forKey: .withdrawalTxHash)
    }
}
