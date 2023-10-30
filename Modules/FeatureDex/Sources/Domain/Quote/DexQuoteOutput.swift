// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import ToolKit

public struct DexQuoteOutput: Equatable {

    public enum Field {
        case source
        case destination
    }

    public enum FeeType: Equatable {
        case network
        case express
        case total
    }

    public struct Fee: Equatable {
        public let type: FeeType
        public let value: CryptoValue
        public init(type: FeeType, value: CryptoValue) {
            self.type = type
            self.value = value
        }
    }

    public struct BuyAmount: Equatable {
        public let amount: CryptoValue
        public let minimum: CryptoValue?
    }

    public let buyAmount: BuyAmount
    public let field: Field
    public let isValidated: Bool
    public let sellAmount: CryptoValue
    public let slippage: String
    public let fees: [Fee]
    public let allowanceSpender: String

    public var networkFee: CryptoValue? {
        fees.first(where: { $0.type == .network })?.value
    }

    public let response: DexQuoteResponse

    init(
        response: DexQuoteResponse,
        allowanceSpender: String,
        buyAmount: BuyAmount,
        field: Field,
        isValidated: Bool,
        fees: [Fee],
        sellAmount: CryptoValue,
        slippage: String
    ) {
        self.allowanceSpender = allowanceSpender
        self.buyAmount = buyAmount
        self.field = field
        self.isValidated = isValidated
        self.sellAmount = sellAmount
        self.slippage = slippage
        self.response = response
        self.fees = fees
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

        let fees = response.quote.fees
            .compactMap { fee in
                fee.outputFee(currenciesService: currenciesService)
            }

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
            response: response,
            allowanceSpender: response.quote.spenderAddress,
            buyAmount: BuyAmount(amount: buyAmount, minimum: minimumBuyAmount),
            field: field,
            isValidated: !request.params.skipValidation,
            fees: fees,
            sellAmount: sellAmount,
            slippage: request.params.slippage
        )
    }
}


extension DexQuoteResponse.FeeType {
    var outputFeeType: DexQuoteOutput.FeeType? {
        switch self {
        case .express:
            return .express
        case .network:
            return .network
        case .total:
            return .total
        default:
            return nil
        }
    }
}

extension DexQuoteResponse.Fee {
    func outputFee(currenciesService: EnabledCurrenciesServiceAPI) -> DexQuoteOutput.Fee? {
        guard let type = type.outputFeeType else {
            return nil
        }
        guard let currency = cryptoCurrency(code: symbol, address: nil, currenciesService) else {
            return nil
        }
        guard let value = CryptoValue.create(minor: amount, currency: currency) else {
            return nil
        }
        return DexQuoteOutput.Fee(type: type, value: value)
    }
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
    public static let nativeAssetAddress: String = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
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
                fees: [
                    .init(type: .express, symbol: "USDT", amount: "0"),
                    .init(type: .network, symbol: "USDT", amount: "0"),
                    .init(type: .total, symbol: "USDT", amount: "0")
                ],
                spenderAddress: ""
            ),
            tx: .init(data: "", gasLimit: "0", gasPrice: "0", value: "0", to: ""),
            legs: 1,
            quoteTtl: 15000
        )
        return DexQuoteOutput(
            response: response,
            allowanceSpender: "",
            buyAmount: BuyAmount(
                amount: CryptoValue.create(major: Double(5), currency: buy),
                minimum: nil
            ),
            field: .source,
            isValidated: false,
            fees: [
                .init(type: .express, value: .create(major: Double(0.111), currency: .ethereum)),
                .init(type: .network, value: .create(major: Double(0.222), currency: .ethereum)),
                .init(type: .total, value: .create(major: Double(0.333), currency: .ethereum))
            ],
            sellAmount: sell,
            slippage: "0.003"
        )
    }
}
