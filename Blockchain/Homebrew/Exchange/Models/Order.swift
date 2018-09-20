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

struct OrderResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let pair: String
    let quantity: String
    let currency: String
    let refundAddress: String
    let price: String
    let depositAddress: String
    let depositQuantity: String
    let withdrawalAddress: String
    let withdrawalQuantity: String
    let state: String

    private enum CodingKeys: CodingKey {
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
    }
}

@objc class OrderTransactionLegacy: NSObject {
    init(
        legacyAssetType: LegacyAssetType,
        from: Int32,
        to: String,
        amount: String,
        fees: String?
    ) {
        self.legacyAssetType = legacyAssetType
        self.from = from
        self.to = to
        self.amount = amount
        self.fees = fees
        super.init()
    }
    @objc let legacyAssetType: LegacyAssetType
    @objc let from: Int32
    @objc let to: String
    @objc let amount: String
    @objc var fees: String?
}

struct OrderTransaction {
    let from: AssetAccount
    let to: AssetAddress
    let amountToSend: String
    let amountToReceive: String
    let fees: String
}
