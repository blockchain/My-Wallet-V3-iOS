// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct DexQuoteResponse: Decodable, Equatable {

    public struct FeeType: NewTypeString, Decodable {
        public let value: String
        public init(_ value: String) { self.value = value }

        static let network: FeeType = "GAS_FEE"
        static let express: FeeType = "EXPRESS_FEE"
        static let crossChain: FeeType = "XC_SWAP_FEE"
        static let total: FeeType = "TOTAL_FEE"
    }

    public struct Fee: Decodable, Equatable {
        let type: FeeType
        let symbol: String
        let amount: String
    }

    public struct Quote: Decodable, Equatable {
        public let buyAmount: Amount
        public let sellAmount: Amount
        public let fees: [Fee]
        public let bcdcFeePercentage: String
        public let spenderAddress: String

        init(buyAmount: Amount, sellAmount: Amount, fees: [Fee], bcdcFeePercentage: String, spenderAddress: String) {
            self.buyAmount = buyAmount
            self.sellAmount = sellAmount
            self.fees = fees
            self.bcdcFeePercentage = bcdcFeePercentage
            self.spenderAddress = spenderAddress
        }
    }

    public struct Amount: Decodable, Equatable {
        public let address: String?
        public let amount: String
        public let minAmount: String?
        public let symbol: String

        init(address: String? = nil, amount: String, minAmount: String? = nil, symbol: String) {
            self.address = address
            self.amount = amount
            self.minAmount = minAmount
            self.symbol = symbol
        }
    }

    public struct Transaction: Decodable, Equatable {
        public let data: String
        public let gasLimit: String
        public let gasPrice: String
        public let value: String
        public let to: String

        init(data: String, gasLimit: String, gasPrice: String, value: String, to: String) {
            self.data = data
            self.gasLimit = gasLimit
            self.gasPrice = gasPrice
            self.value = value
            self.to = to
        }
    }

    public let approxConfirmationTime: Int?
    public let quoteTtl: Double
    public let quote: Quote
    public let tx: Transaction

    init(approxConfirmationTime: Int?, quote: Quote, tx: Transaction, quoteTtl: Double) {
        self.approxConfirmationTime = approxConfirmationTime
        self.quote = quote
        self.tx = tx
        self.quoteTtl = quoteTtl
    }
}
