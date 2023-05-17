// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct DexQuoteResponse: Decodable, Equatable {

    public struct Quote: Decodable, Equatable {
        public var buyAmount: Amount
        public var sellAmount: Amount

        public var buyTokenFee: String
        // var buyTokenPercentageFee: String
        // var estimatedPriceImpact: String
        // var guaranteedPrice: String
        // var price: String

        init(buyAmount: Amount, sellAmount: Amount, buyTokenFee: String) {
            self.buyAmount = buyAmount
            self.sellAmount = sellAmount
            self.buyTokenFee = buyTokenFee
        }
    }

    public struct Amount: Decodable, Equatable {
        public var address: String?
        public var amount: String
        public var chainId: Int
        public var minAmount: String?
        public var symbol: String

        init(address: String? = nil, amount: String, chainId: Int, minAmount: String? = nil, symbol: String) {
            self.address = address
            self.amount = amount
            self.chainId = chainId
            self.minAmount = minAmount
            self.symbol = symbol
        }
    }

    // var type: String
    // var venueType: String
    // var legs: Int
    // var approxConfirmationTime: Int // in seconds
    // var quoteTtl: Int // in milli seconds

    public var quote: Quote
    public var tx: JSONValue

    init(quote: Quote, tx: JSONValue) {
        self.quote = quote
        self.tx = tx
    }
}
