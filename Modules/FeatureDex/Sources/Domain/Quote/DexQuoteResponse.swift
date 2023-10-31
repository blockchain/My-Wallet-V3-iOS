// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct DexQuoteResponse: Decodable, Equatable {

    public struct FeeType: NewTypeString, Decodable {
        public let value: String
        public init(_ value: String) { self.value = value }

        static let network: FeeType = "GAS_FEE"
        static let crossChain: FeeType = "XC_SWAP_FEE"
        static let total: FeeType = "TOTAL_FEE"
    }

    public struct Fee: Decodable, Equatable {
        let type: FeeType
        let symbol: String
        let amount: String
    }

    public struct Quote: Decodable, Equatable {
        public var buyAmount: Amount
        public var sellAmount: Amount
        public var fees: [Fee]
        public var spenderAddress: String

        init(buyAmount: Amount, sellAmount: Amount, fees: [Fee], spenderAddress: String) {
            self.buyAmount = buyAmount
            self.sellAmount = sellAmount
            self.fees = fees
            self.spenderAddress = spenderAddress
        }
    }

    public struct Amount: Decodable, Equatable {
        public var address: String?
        public var amount: String
        public var minAmount: String?
        public var symbol: String

        init(address: String? = nil, amount: String, minAmount: String? = nil, symbol: String) {
            self.address = address
            self.amount = amount
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

    public var quoteTtl: Double
    public var quote: Quote
    public var tx: Transaction

    init(quote: Quote, tx: Transaction, quoteTtl: Double) {
        self.quote = quote
        self.tx = tx
        self.quoteTtl = quoteTtl
    }
}
