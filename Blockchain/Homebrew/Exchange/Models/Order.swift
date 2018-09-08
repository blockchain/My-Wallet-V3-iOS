//
//  Order.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

enum Side: String {
    case buy = "BUY"
    case sell = "SELL"
}

struct Order: Encodable {
    
    let pair: TradingPair
    let side: Side
    let quantity: Double
    let destinationAddress: String
    let refundAddress: String
    
    enum CodingKeys: String, CodingKey {
        case side
        case pair
        case quantity
        case destinationAddress
        case refundAddress
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let pairValue = pair.stringRepresentation
        
        try container.encode(side.rawValue, forKey: .side)
        try container.encode(pairValue, forKey: .pair)
        try container.encodeIfPresent(String(quantity), forKey: .quantity)
        try container.encode(destinationAddress, forKey: .destinationAddress)
        try container.encode(refundAddress, forKey: .refundAddress)
    }
}
