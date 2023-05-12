// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct DexQuoteResponse: Decodable, Equatable {

    public struct Quote: Decodable, Equatable {
        public var buyAmount: Amount
        public var sellAmount: Amount

        // var buyTokenFee: String
        // var buyTokenPercentageFee: String
        // var estimatedPriceImpact: String
        // var guaranteedPrice: String
        // var price: String

        init(buyAmount: Amount, sellAmount: Amount) {
            self.buyAmount = buyAmount
            self.sellAmount = sellAmount
        }
    }

    public struct Transaction: Decodable, Equatable {
        public var allowanceTarget: String
        public var chainId: Int
        public var data: String
        public var gasLimit: String // TODO: will be used for native currency fee
        public var gasPrice: String // TODO: will be used for native currency fee
        public var to: String
        public var value: String

        init(allowanceTarget: String, chainId: Int, data: String, gasLimit: String, gasPrice: String, to: String, value: String) {
            self.allowanceTarget = allowanceTarget
            self.chainId = chainId
            self.data = data
            self.gasLimit = gasLimit
            self.gasPrice = gasPrice
            self.to = to
            self.value = value
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
    public var tx: Transaction

    init(quote: Quote, tx: Transaction) {
        self.quote = quote
        self.tx = tx
    }
}
