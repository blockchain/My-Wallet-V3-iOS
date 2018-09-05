//
//  TradingPairConfiguration.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct TradingPairConfiguration: Decodable {
    let pair: TradingPair
    let priceIncrement: Double
    let orderIncrement: Double
    let minimumOrderSize: Double
    
    enum CodingKeys: String, CodingKey {
        case pair
        case priceIncrement
        case orderIncrement
        case minOrderSize
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let string = try values.decode(String.self, forKey: .pair)
        if let value = TradingPair(string: string) {
            pair = value
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.pair],
                debugDescription: "Expected trading pair from \(string)"
            )
            throw DecodingError.valueNotFound(TradingPair.self, context)
        }
        
        let price = try values.decode(String.self, forKey: .priceIncrement)
        let order = try values.decode(String.self, forKey: .orderIncrement)
        let size = try values.decode(String.self, forKey: .minOrderSize)
        if let value = Double(price) {
            priceIncrement = value
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.priceIncrement],
                debugDescription: "Expected trading pair from \(price)"
            )
            throw DecodingError.valueNotFound(Double.self, context)
        }
        if let value = Double(order) {
            orderIncrement = value
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.orderIncrement],
                debugDescription: "Expected trading pair from \(order)"
            )
            throw DecodingError.valueNotFound(Double.self, context)
        }
        if let value = Double(size) {
            minimumOrderSize = value
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.minOrderSize],
                debugDescription: "Expected trading pair from \(size)"
            )
            throw DecodingError.valueNotFound(Double.self, context)
        }
    }
}
