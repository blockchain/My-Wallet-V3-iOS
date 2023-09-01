// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain

public struct CurrencyFeeResponse: Decodable {
    public let symbol: String
    public let minorValue: String
}

public struct WithdrawFeesResponse: Decodable {
    public let fees: [CurrencyFeeResponse]
    public let minAmounts: [CurrencyFeeResponse]
}

extension CurrencyFeeResponse {
    public static func zero(currency: Currency) -> CurrencyFeeResponse {
        CurrencyFeeResponse(symbol: currency.code, minorValue: "0")
    }
}
