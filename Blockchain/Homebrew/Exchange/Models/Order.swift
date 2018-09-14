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

// Backend is currently configured to return two types of responses:
// a normal (success) response and an error response
struct OrderResult: Codable {
    // Success
    let id: String?
    let createdAt: String?
    let updatedAt: String?
    let pair: String?
    let quantity: String?
    let currency: String?
    let refundAddress: String?
    let price: String?
    let depositAddress: String?
    let depositQuantity: String?
    let withdrawalAddress: String?
    let withdrawalQuantity: String?
    let state: String?

    // Error
    let type: String?
    let description: String??

    private enum CodingKeys: CodingKey {
        // Success
        case id
        case createdAt
        case updatedAt
        case pair
        case quantity
        case currency
        case refundAddress
        case price
        case depositAddress
        case depositQuantity
        case withdrawalAddress
        case withdrawalQuantity
        case state
        
        // Error
        case type
        case description
    }
}
