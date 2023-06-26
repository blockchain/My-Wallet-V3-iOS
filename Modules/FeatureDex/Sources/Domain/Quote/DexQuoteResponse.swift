// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct DexQuoteResponse: Decodable, Equatable {

    public struct Quote: Decodable, Equatable {
        public var buyAmount: Amount
        public var sellAmount: Amount
        public var buyTokenFee: String
        public var gasFee: String

        init(buyAmount: Amount, sellAmount: Amount, buyTokenFee: String, gasFee: String) {
            self.buyAmount = buyAmount
            self.sellAmount = sellAmount
            self.buyTokenFee = buyTokenFee
            self.gasFee = gasFee
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
        public var gasPrice: String
        public var value: String
        public var to: String

        init(data: String, gasLimit: String, gasPrice: String, value: String, to: String) {
            self.data = data
            self.gasLimit = gasLimit
            self.gasPrice = gasPrice
            self.value = value
            self.to = to
        }
    }

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
