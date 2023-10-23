// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import ToolKit

public struct DexQuoteOutput: Equatable {

    public enum Field {
        case source
        case destination
    }

    public struct BuyAmount: Equatable {
        public let amount: CryptoValue
        public let minimum: CryptoValue?
    }

    public let buyAmount: BuyAmount
    public let field: Field
    public let isValidated: Bool
    public let networkFee: CryptoValue
    public let sellAmount: CryptoValue
    public let slippage: String

    public let response: DexQuoteResponse

    init(
        buyAmount: BuyAmount,
        field: Field,
        isValidated: Bool,
        networkFee: CryptoValue,
        sellAmount: CryptoValue,
        slippage: String,
        response: DexQuoteResponse
    ) {
        self.buyAmount = buyAmount
        self.field = field
        self.isValidated = isValidated
        self.networkFee = networkFee
        self.sellAmount = sellAmount
        self.slippage = slippage
        self.response = response
    }

    public init?(
        request: DexQuoteRequest,
        response: DexQuoteResponse,
        currenciesService: EnabledCurrenciesServiceAPI
    ) {
        guard response.legs == 1 else {
            // Current implementation only supports 1-leg transactions.
            return nil
        }

        guard let sellCurrency = cryptoCurrency(
            code: response.quote.sellAmount.symbol,
            address: response.quote.sellAmount.address,
            currenciesService
        ) else { return nil }

        guard let sellNetwork = currenciesService
            .network(for: sellCurrency)
        else { return nil }

        guard let networkFee = CryptoValue.create(
            minor: response.quote.gasFee,
            currency: sellNetwork.nativeAsset
        ) else { return nil }

        guard let buyAmount = cryptoValue(from: response.quote.buyAmount, currenciesService: currenciesService) else {
            return nil
        }
        guard let sellAmount = cryptoValue(from: response.quote.sellAmount, currenciesService: currenciesService) else {
            return nil
        }

        let minimumBuyAmount: CryptoValue? = minumumCryptoValue(
            from: response.quote.buyAmount,
            currenciesService: currenciesService
        )

        guard let field = FeatureDexDomain.field(from: request) else { return nil }

        self.init(
            buyAmount: BuyAmount(amount: buyAmount, minimum: minimumBuyAmount),
            field: field,
            isValidated: !request.params.skipValidation,
            networkFee: networkFee,
            sellAmount: sellAmount,
            slippage: request.params.slippage,
            response: response
        )
    }
}

private func networkFee(
    quote: DexQuoteResponse.Quote,
    currenciesService: EnabledCurrenciesServiceAPI
) -> CryptoValue? {
    let sellCurrency = cryptoCurrency(
        code: quote.sellAmount.symbol,
        address: quote.sellAmount.address,
        currenciesService
    )
    guard let sellCurrency else { return nil }
    guard let sellNetwork = currenciesService.network(for: sellCurrency) else {
        return nil
    }
    let value = CryptoValue.create(
        minor: quote.gasFee,
        currency: sellNetwork.nativeAsset
    )
    return value
}

private func minumumCryptoValue(
    from amount: DexQuoteResponse.Amount,
    currenciesService: EnabledCurrenciesServiceAPI
) -> CryptoValue? {
    guard let minAmount = amount.minAmount else {
        return nil
    }
    let currency = cryptoCurrency(
        code: amount.symbol,
        address: amount.address,
        currenciesService
    )
    guard let currency else { return nil }
    let value = CryptoValue.create(
        minor: minAmount,
        currency: currency
    )
    return value
}

private func cryptoValue(
    from amount: DexQuoteResponse.Amount,
    currenciesService: EnabledCurrenciesServiceAPI
) -> CryptoValue? {
    let currency = cryptoCurrency(
        code: amount.symbol,
        address: amount.address,
        currenciesService
    )
    guard let currency else { return nil }
    let value = CryptoValue.create(
        minor: amount.amount,
        currency: currency
    )
    return value
}

private func field(from request: DexQuoteRequest) -> DexQuoteOutput.Field? {
    let isSource = request.fromCurrency.amount != nil
    let isDestination = request.toCurrency.amount != nil
    guard isSource != isDestination else {
        return nil
    }
    return isSource ? .source : .destination
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
                buyAmount: .init(amount: "0", symbol: "USDT"),
                sellAmount: .init(amount: "0", symbol: "USDT"),
                bcdcFee: .init(amount: "111000", symbol: "USDT"),
                gasFee: "777000000"
            ),
            tx: .init(data: "", gasLimit: "0", gasPrice: "0", value: "0", to: ""),
            legs: 1,
            quoteTtl: 15000
        )
        return DexQuoteOutput(
            buyAmount: BuyAmount(
                amount: CryptoValue.create(major: Double(5), currency: buy),
                minimum: nil
            ),
            field: .source,
            isValidated: false,
            networkFee: .create(major: Double(0.125), currency: .ethereum),
            sellAmount: sell,
            slippage: "0.003",
            response: response
        )
    }
}
