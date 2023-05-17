// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import ToolKit

public struct DexQuoteOutput: Equatable {

    public struct BuyAmount: Equatable {
        public let amount: CryptoValue
        public let minimum: CryptoValue?
    }

    public let buyAmount: BuyAmount
    public let sellAmount: CryptoValue
    public let productFee: CryptoValue
    public let isValidated: Bool

    let response: DexQuoteResponse

    init(
        buyAmount: BuyAmount,
        sellAmount: CryptoValue,
        productFee: CryptoValue,
        isValidated: Bool,
        response: DexQuoteResponse
    ) {
        self.buyAmount = buyAmount
        self.sellAmount = sellAmount
        self.isValidated = isValidated
        self.productFee = productFee
        self.response = response
    }

    public init?(
        isValidated: Bool,
        response: DexQuoteResponse,
        currenciesService: EnabledCurrenciesServiceAPI
    ) {
        guard let buyCurrency = cryptoCurrency(
            code: response.quote.buyAmount.symbol,
            address: response.quote.buyAmount.address,
            currenciesService
        ) else { return nil }

        guard let sellCurrency = cryptoCurrency(
            code: response.quote.sellAmount.symbol,
            address: response.quote.sellAmount.address,
            currenciesService
        ) else { return nil }

        guard let buyAmount = CryptoValue.create(
            minor: response.quote.buyAmount.amount,
            currency: buyCurrency
        ) else { return nil }

        guard let sellAmount = CryptoValue.create(
            minor: response.quote.sellAmount.amount,
            currency: sellCurrency
        ) else { return nil }

        guard let productFee = CryptoValue.create(
            minor: response.quote.buyTokenFee,
            currency: buyCurrency
        ) else { return nil }

        let minimum: CryptoValue? = response.quote.buyAmount.minAmount
            .flatMap { minAmount in
                CryptoValue.create(
                    minor: minAmount,
                    currency: buyCurrency
                )
            }

        self.init(
            buyAmount: BuyAmount(amount: buyAmount, minimum: minimum),
            sellAmount: sellAmount,
            productFee: productFee,
            isValidated: isValidated,
            response: response
        )
    }
}

private func cryptoCurrency(
    code: String,
    address: String?,
    _ service: EnabledCurrenciesServiceAPI
) -> CryptoCurrency? {
    guard let currency = service.allEnabledCryptoCurrencies.first(where: { $0.code == code }) else {
        return nil
    }
    if let address {
        let contract = currency.assetModel.kind.erc20ContractAddress ?? Constants.nativeAssetAddress
        guard contract.caseInsensitiveCompare(address) == .orderedSame else {
            return nil
        }
    }
    return currency
}

public enum Constants {
    public static let nativeAssetAddress: String = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
    public static let spender: String = "ZEROX_EXCHANGE"
}

extension DexQuoteOutput {
    public static func preview(
        buy: CryptoCurrency,
        sell: CryptoValue
    ) -> DexQuoteOutput {
        let response = DexQuoteResponse(
            quote: .init(
                buyAmount: .init(amount: "0", chainId: 1, symbol: "USDT"),
                sellAmount: .init(amount: "0", chainId: 1, symbol: "USDT"),
                buyTokenFee: "0"
            ),
            tx: JSONValue.null
        )
        return DexQuoteOutput(
            buyAmount: BuyAmount(
                amount: CryptoValue.create(major: Double(5), currency: buy),
                minimum: nil
            ),
            sellAmount: sell,
            productFee: CryptoValue.create(major: Double(0.5), currency: buy),
            isValidated: false,
            response: response
        )
    }
}
