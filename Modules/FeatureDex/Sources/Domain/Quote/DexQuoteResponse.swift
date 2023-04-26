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
    }

    public struct Transaction: Decodable, Equatable {
        var allowanceTarget: String
        var chainId: Int
        var data: String
        var gasLimit: String
        var gasPrice: String
        var to: String
        var value: String
    }

    public struct Amount: Decodable, Equatable {
        public var address: String?
        public var amount: String
        public var chainId: Int
        public var minAmount: String?
        public var symbol: String
    }

    // var type: String
    // var venueType: String
    // var legs: Int
    // var approxConfirmationTime: Int // in seconds
    // var quoteTtl: Int // in milli seconds

    public var quote: Quote
    public var tx: Transaction
}
