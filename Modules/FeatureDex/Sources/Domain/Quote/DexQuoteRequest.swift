// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct DexQuoteRequest: Encodable, Equatable {

    public struct FromCurrency: Encodable, Equatable {
        var chainId: Int
        var symbol: String
        var address: String
        var amount: String

        public init(chainId: Int, symbol: String, address: String, amount: String) {
            self.chainId = chainId
            self.symbol = symbol
            self.address = address
            self.amount = amount
        }
    }

    public struct ToCurrency: Encodable, Equatable {
        var chainId: Int
        var symbol: String
        var address: String

        public init(chainId: Int, symbol: String, address: String) {
            self.chainId = chainId
            self.symbol = symbol
            self.address = address
        }
    }

    public struct Params: Encodable, Equatable {
        var slippage: String
        var skipValidation: Bool

        public init(slippage: String, skipValidation: Bool) {
            self.slippage = slippage
            self.skipValidation = skipValidation
        }
    }

    private var venue: DexQuoteVenue
    private var fromCurrency: FromCurrency
    private var toCurrency: ToCurrency
    private var takerAddress: String
    private var params: Params

    public var skipValidation: Bool { params.skipValidation }

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
}
