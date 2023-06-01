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

    public struct Transaction: Decodable, Equatable {
        public var data: String
        public var gasLimit: String
        public var value: String
        public var to: String

        init(data: String, gasLimit: String, value: String, to: String) {
            self.data = data
            self.gasLimit = gasLimit
            self.value = value
            self.to = to
        }
    }
    
    // var type: String
    // var approxConfirmationTime: Int
    // var venueType: String
    public var legs: Int
    public var quoteTtl: Double
    public var quote: Quote
    public var tx: Transaction

    init(quote: Quote, tx: Transaction, legs: Int, quoteTtl: Double) {
        self.quote = quote
        self.tx = tx
        self.legs = legs
        self.quoteTtl = quoteTtl
    }
}
