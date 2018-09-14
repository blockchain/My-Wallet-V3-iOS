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
    let destinationAddress: String
    let refundAddress: String
    let quote: Quote
}

struct TradeExecutionResult: Codable {
    // Error
    let type: String?
    let description: String?
    private enum CodingKeys: CodingKey {
        // Error
        case type
        case description
    }
}
