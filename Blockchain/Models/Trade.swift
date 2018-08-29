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
struct Trade: Decodable {
    
    let identifier: String
    let created: Date
    let updated: Date
    let pair: TradingPair
    let side: Side
    let quantity: Double
    let currency: AssetType
    let refundAddress: String
    let price: Double
    let depositAddress: String
    let depositQuantity: Double
    let withdrawalAddress: String
    let withdrawalQuantity: Double
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
        
        quantity = try values.decode(String.self, forKey: .quantity).toDouble()
        refundAddress = try values.decode(String.self, forKey: .refundAddress)
        price = try values.decode(String.self, forKey: .price).toDouble()
        depositAddress = try values.decode(String.self, forKey: .depositAddress)
        depositQuantity = try values.decode(String.self, forKey: .depositQuantity).toDouble()
        withdrawalAddress = try values.decode(String.self, forKey: .withdrawlAddress)
        withdrawalQuantity = try values.decode(String.self, forKey: .withdrawlQuantity).toDouble()
        depositHash = try values.decode(String.self, forKey: .depositTxHash)
        withdrawalHash = try values.decode(String.self, forKey: .withdrawalTxHash)
    }
}
