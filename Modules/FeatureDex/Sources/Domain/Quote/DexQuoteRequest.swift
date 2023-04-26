// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct DexQuoteRequest: Encodable, Equatable {
    public init(
        venue: DexQuoteVenue,
        fromCurrency: FromCurrency,
        toCurrency: ToCurrency,
        takerAddress: String,
        params: Params
    ) {
        self.venue = venue
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.takerAddress = takerAddress
        self.params = params
    }

    public struct FromCurrency: Encodable, Equatable {
        public init(chainId: Int, symbol: String, address: String, amount: String) {
            self.chainId = chainId
            self.symbol = symbol
            self.address = address
            self.amount = amount
        }

        private var chainId: Int
        private var symbol: String
        private var address: String
        private var amount: String
    }

    public struct ToCurrency: Encodable, Equatable {
        public init(chainId: Int, symbol: String, address: String) {
            self.chainId = chainId
            self.symbol = symbol
            self.address = address
        }

        private var chainId: Int
        private var symbol: String
        private var address: String
    }

    public struct Params: Encodable, Equatable {
        public init(slippage: String, skipValidation: Bool) {
            self.slippage = slippage
            self.skipValidation = skipValidation
        }

        private var slippage: String
        private var skipValidation: Bool
    }

    private var venue: DexQuoteVenue
    private var fromCurrency: FromCurrency
    private var toCurrency: ToCurrency
    private var takerAddress: String
    private var params: Params
}
