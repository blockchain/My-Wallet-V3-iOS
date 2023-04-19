// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import NetworkKit
import PlatformKit
import ToolKit

typealias FeatureTransactionDomainClientAPI = CustodialQuoteAPI &
    OrderCreationClientAPI &
    AvailablePairsClientAPI &
    TransactionLimitsClientAPI &
    OrderFetchingClientAPI &
    OrderUpdateClientAPI &
    CustodialTransferClientAPI &
    BitPayClientAPI &
    BlockchainNameResolutionClientAPI &
    BankTransferClientAPI &
    WithdrawalLocksCheckClientAPI &
    CreateRecurringBuyClientAPI &
    CancelRecurringBuyClientAPI &
    RecurringBuyProviderClientAPI &
    EligiblePaymentMethodRecurringBuyClientAPI

/// FeatureTransactionDomain network client
final class APIClient: FeatureTransactionDomainClientAPI {

    fileprivate enum Parameter {
        static let minor = "minor"
        static let currency = "currency"
        static let date = "date"
        static let inputCurrency = "inputCurrency"
        static let fromAccount = "fromAccount"
        static let outputCurrency = "outputCurrency"
        static let toAccount = "toAccount"
        static let product = "product"
        static let paymentMethod = "paymentMethod"
        static let orderDirection = "orderDirection"
        static let payment = "payment"
        static let simpleBuy = "SIMPLEBUY"
        static let swap = "SWAP"
        static let sell = "SELL"
        static let `default` = "DEFAULT"
        static let cryptoTransfer = "CRYPTO_TRANSFER"
        static let id = "id"
    }

    private enum Path {
        static let quote = ["custodial", "quote"]
        static let createOrder = ["custodial", "trades"]
        static let availablePairs = ["custodial", "trades", "pairs"]
        static let fetchOrder = createOrder
        static let limits = ["trades", "limits"]
        static let crossBorderLimits = ["limits", "crossborder", "transaction"]
        static let transfer = ["payments", "withdrawals"]
        static let bankTransfer = ["payments", "banktransfer"]
        static let transferFees = ["payments", "withdrawals", "fees"]
        static let withdrawalLocksCheck = ["payments", "withdrawals", "locks", "check"]
        static let recurringBuyCreate = ["recurring-buy", "create"]
        static let recurringBuyList = ["recurring-buy", "list"]
        static let recurringBuyNextPayment = ["recurring-buy", "next-payment"]
        static let withdrawalFees = ["withdrawals", "fees"]

        static func cancelRecurringBuy(_ id: String) -> [String] {
            ["recurring-buy", id, "cancel"]
        }

        static func updateOrder(transactionID: String) -> [String] {
            createOrder + [transactionID]
        }
    }

    private enum BitPay {
        static let url: String = "https://bitpay.com/"

        enum Paramter {
            static let invoice: String = "i/"
        }
    }

    private let retailNetworkAdapter: NetworkAdapterAPI
    private let retailRequestBuilder: RequestBuilder
    private let defaultNetworkAdapter: NetworkAdapterAPI
    private let defaultRequestBuilder: RequestBuilder

    init(
        retailNetworkAdapter: NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail),
        retailRequestBuilder: RequestBuilder = DIKit.resolve(tag: DIKitContext.retail),
        defaultNetworkAdapter: NetworkAdapterAPI = DIKit.resolve(),
        defaultRequestBuilder: RequestBuilder = DIKit.resolve()
    ) {
        self.retailNetworkAdapter = retailNetworkAdapter
        self.retailRequestBuilder = retailRequestBuilder
        self.defaultNetworkAdapter = defaultNetworkAdapter
        self.defaultRequestBuilder = defaultRequestBuilder
    }
}

// MARK: - AvailablePairsClientAPI

extension APIClient {

    var availableOrderPairs: AnyPublisher<AvailableTradingPairsResponse, NabuNetworkError> {
        let request = retailRequestBuilder.get(
            path: Path.availablePairs,
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - CustodialQuoteAPI

extension APIClient {

    func fetchQuoteResponse(
        with request: OrderQuoteRequest
    ) -> AnyPublisher<OrderQuoteResponse, NabuNetworkError> {
        let request = retailRequestBuilder.post(
            path: Path.quote,
            body: try? request.encode(),
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - OrderCreationClientAPI

extension APIClient {

    func create(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError> {
        create(
            direction: direction,
            quoteIdentifier: quoteIdentifier,
            volume: volume,
            destinationAddress: destinationAddress,
            refundAddress: refundAddress,
            ccy: nil
        )
    }

    func create(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        ccy: String?,
        refundAddress: String?
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError> {
        create(
            direction: direction,
            quoteIdentifier: quoteIdentifier,
            volume: volume,
            destinationAddress: nil,
            refundAddress: refundAddress,
            ccy: ccy
        )
    }

    private func create(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?,
        ccy: String?
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError> {
        let body = OrderCreationRequest(
            direction: direction,
            quoteId: quoteIdentifier,
            volume: volume,
            destinationAddress: destinationAddress,
            refundAddress: refundAddress,
            ccy: ccy
        )
        let request = retailRequestBuilder.post(
            path: Path.createOrder,
            body: try? body.encode(),
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - OrderUpdateClientAPI

extension APIClient {

    func updateOrder(
        with transactionId: String,
        success: Bool
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = OrderUpdateRequest(success: success)
        let request = retailRequestBuilder.post(
            path: Path.updateOrder(transactionID: transactionId),
            body: try? payload.encode(),
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - OrderFetchingClientAPI

extension APIClient {

    func fetchTransaction(
        with transactionId: String
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError> {
        let request = retailRequestBuilder.get(
            path: Path.fetchOrder + [transactionId],
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - CustodialTransferClientAPI

extension APIClient {

    func send(
        transferRequest: CustodialTransferRequest
    ) -> AnyPublisher<CustodialTransferResponse, NabuNetworkError> {
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let request = retailRequestBuilder.post(
            path: Path.transfer,
            body: try? transferRequest.encode(),
            headers: headers,
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    func custodialTransferFeesForProduct(
        _ product: Product
    ) -> AnyPublisher<CustodialTransferFeesResponse, NabuNetworkError> {
        let parameters: [URLQueryItem] = [
            URLQueryItem(name: Parameter.product, value: product.rawValue),
            URLQueryItem(name: Parameter.paymentMethod, value: Parameter.default)
        ]
        let request = retailRequestBuilder.get(
            path: Path.transferFees,
            parameters: parameters,
            authenticated: false
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    func custodialTransferFees() -> AnyPublisher<CustodialTransferFeesResponse, NabuNetworkError> {
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let parameters: [URLQueryItem] = [
            URLQueryItem(name: Parameter.product, value: Parameter.simpleBuy),
            URLQueryItem(name: Parameter.paymentMethod, value: Parameter.default)
        ]
        let request = retailRequestBuilder.get(
            path: Path.transferFees,
            parameters: parameters,
            headers: headers,
            authenticated: false
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    func custodialWithdrawalFees(
        currency: String,
        fiatCurrency: String,
        amount: String,
        max: Bool
    ) -> AnyPublisher<WithdrawalFeesResponse, NabuNetworkError> {
        let parameters: [URLQueryItem] = [
            URLQueryItem(name: Parameter.currency, value: currency),
            URLQueryItem(name: Parameter.paymentMethod, value: Parameter.cryptoTransfer),
            URLQueryItem(name: Parameter.product, value: "WALLET"),
            URLQueryItem(name: "amount", value: amount),
            URLQueryItem(name: "fiatCurrency", value: fiatCurrency),
            URLQueryItem(name: "max", value: String(max))
        ]
        let request = retailRequestBuilder.get(
            path: Path.withdrawalFees,
            parameters: parameters,
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - BankTransferClientAPI

extension APIClient {

    func startBankTransfer(
        id: String,
        amount: MoneyValue
    ) -> AnyPublisher<BankTranferPaymentResponse, NabuNetworkError> {
        let model = BankTransferPaymentRequest(
            amountMinor: amount.minorString,
            currency: amount.code,
            attributes: nil
        )
        let request = retailRequestBuilder.post(
            path: Path.bankTransfer + [id] + [Parameter.payment],
            body: try? model.encode(),
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    func createWithdrawOrder(id: String, amount: MoneyValue) -> AnyPublisher<Void, NabuNetworkError> {
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let body = WithdrawRequestBody(
            beneficiary: id,
            currency: amount.code,
            amount: amount.minorString
        )
        let request = retailRequestBuilder.post(
            path: Path.transfer,
            body: try? body.encode(),
            headers: headers,
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - BitPayClientAPI

extension APIClient {

    func bitpayPaymentRequest(
        invoiceId: String,
        currency: CryptoCurrency
    ) -> AnyPublisher<BitpayPaymentRequestResponse, NetworkError> {
        let payload = ["chain": currency.code]
        let headers = [
            HttpHeaderField.xPayProVersion: HttpHeaderValue.xPayProVersion,
            HttpHeaderField.contentType: HttpHeaderValue.bitpayPaymentRequest,
            HttpHeaderField.bitpayPartner: HttpHeaderValue.bitpayPartnerName,
            HttpHeaderField.bitpayPartnerVersion: HttpHeaderValue.bitpayPartnerVersion
        ]
        let url = URL(string: BitPay.url + BitPay.Paramter.invoice + invoiceId)!
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: headers
        )
        return retailNetworkAdapter.perform(request: request)
    }

    func verifySignedTransaction(
        invoiceId: String,
        currency: CryptoCurrency,
        transactionHex: String,
        transactionSize: Int
    ) -> AnyPublisher<Void, NetworkError> {
        let transaction = BitPayPaymentRequest.Transaction(
            tx: transactionHex,
            weightedSize: transactionSize
        )
        let payload = BitPayPaymentRequest(
            chain: currency.code,
            transactions: [transaction]
        )
        let headers = [
            HttpHeaderField.xPayProVersion: HttpHeaderValue.xPayProVersion,
            HttpHeaderField.contentType: HttpHeaderValue.bitpayPaymentVerification,
            HttpHeaderField.bitpayPartner: HttpHeaderValue.bitpayPartnerName,
            HttpHeaderField.bitpayPartnerVersion: HttpHeaderValue.bitpayPartnerVersion
        ]
        let url = URL(string: BitPay.url + BitPay.Paramter.invoice + invoiceId)!
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: headers
        )
        return retailNetworkAdapter.perform(request: request)
    }

    func postPayment(
        invoiceId: String,
        currency: CryptoCurrency,
        transactionHex: String,
        transactionSize: Int
    ) -> AnyPublisher<BitPayMemoResponse, NetworkError> {
        let transaction = BitPayPaymentRequest.Transaction(
            tx: transactionHex,
            weightedSize: transactionSize
        )
        let payload = BitPayPaymentRequest(
            chain: currency.code,
            transactions: [transaction]
        )
        let headers = [
            HttpHeaderField.xPayProVersion: HttpHeaderValue.xPayProVersion,
            HttpHeaderField.contentType: HttpHeaderValue.bitpayPayment,
            HttpHeaderField.bitpayPartner: HttpHeaderValue.bitpayPartnerName,
            HttpHeaderField.bitpayPartnerVersion: HttpHeaderValue.bitpayPartnerVersion
        ]
        let url = URL(string: BitPay.url + BitPay.Paramter.invoice + invoiceId)!
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: headers
        )
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - TransactionLimitsClientAPI

extension APIClient {

    func fetchTradeLimits(
        currency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TradeLimitsResponse, NabuNetworkError> {
        var parameters: [URLQueryItem] = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.code
            ),
            URLQueryItem(
                name: Parameter.minor,
                value: "true"
            )
        ]
        switch product {
        case .swap(let orderDirection):
            parameters.append(
                URLQueryItem(name: Parameter.product, value: Parameter.swap)
            )
            parameters.append(
                URLQueryItem(name: Parameter.orderDirection, value: orderDirection.rawValue)
            )
        case .sell(let orderDirection):
            parameters.append(
                URLQueryItem(name: Parameter.product, value: Parameter.sell)
            )
            parameters.append(
                URLQueryItem(name: Parameter.orderDirection, value: orderDirection.rawValue)
            )
        case .simplebuy:
            parameters.append(
                URLQueryItem(name: Parameter.product, value: Parameter.simpleBuy)
            )
        }
        let request = retailRequestBuilder.get(
            path: Path.limits,
            parameters: parameters,
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    func fetchCrossBorderLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: CurrencyType
    ) -> AnyPublisher<CrossBorderLimitsResponse, NabuNetworkError> {
        let parameters: [URLQueryItem] = [
            URLQueryItem(name: Parameter.currency, value: limitsCurrency.code),
            URLQueryItem(name: Parameter.inputCurrency, value: source.currency.code),
            URLQueryItem(name: Parameter.fromAccount, value: source.accountType.rawValue),
            URLQueryItem(name: Parameter.outputCurrency, value: destination.currency.code),
            URLQueryItem(name: Parameter.toAccount, value: destination.accountType.rawValue)
        ]
        let request = retailRequestBuilder.get(
            path: Path.crossBorderLimits,
            parameters: parameters,
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }
}

// MARK: - BlockchainNameResolutionClientAPI

extension APIClient {

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolutionResponse, NetworkError> {
        let payload = DomainResolutionRequest(currency: currency, name: domainName)
        let request = defaultRequestBuilder.post(
            path: "/explorer-gateway/resolution/resolve",
            body: try? JSONEncoder().encode(payload)
        )!
        return defaultNetworkAdapter.perform(request: request)
    }

    func reverseResolve(
        address: String,
        currency: String
    ) -> AnyPublisher<ReverseResolutionResponse, NetworkError> {
        let payload = ReverseResolutionRequest(
            address: address,
            currency: currency
        )
        let request = defaultRequestBuilder.post(
            path: "/explorer-gateway/resolution/reverse",
            body: try? JSONEncoder().encode(payload)
        )!
        return defaultNetworkAdapter.perform(request: request)
    }
}

// MARK: - TransactionLimitsClientAPI

extension APIClient {

    func fetchWithdrawalLocksCheck(
        paymentMethod: String,
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocksCheckResponse, NabuNetworkError> {
        let body = [
            "paymentMethod": paymentMethod,
            "currency": currencyCode
        ]
        let request = retailRequestBuilder.post(
            path: Path.withdrawalLocksCheck,
            body: try? body.data(),
            authenticated: true
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    // MARK: - CreateRecurringBuyClientAPI

    func createRecurringBuyWithFiatValue(
        _ fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        frequency: RecurringBuy.Frequency,
        paymentMethod: PaymentMethodType
    ) -> AnyPublisher<RecurringBuyResponse, NabuNetworkError> {
        let body = RecurringBuyRequest(
            inputValue: fiatValue.minorString,
            inputCurrency: fiatValue.code,
            destinationCurrency: cryptoCurrency.code,
            paymentMethod: paymentMethod.method.rawType.rawValue,
            period: frequency.rawValue,
            beneficiaryId: paymentMethod.id
        )
        let request = retailRequestBuilder.post(
            path: Path.recurringBuyCreate,
            body: try? body.data(),
            authenticated: true
        )!

        return retailNetworkAdapter.perform(request: request)
    }

    // MARK: - CancelRecurringBuyClientAPI

    func cancelRecurringBuyWithId(_ id: String) -> AnyPublisher<Void, NabuNetworkError> {
        let request = retailRequestBuilder.delete(
            path: Path.cancelRecurringBuy(id),
            authenticated: true
        )!

        return retailNetworkAdapter.perform(request: request)
    }

    // MARK: - RecurringBuyProviderClientAPI

    func fetchRecurringBuysForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency?
    ) -> AnyPublisher<[RecurringBuyResponse], NabuNetworkError> {
        var parameters: [URLQueryItem] = []
        if let cryptoCurrency {
            parameters.append(
                URLQueryItem(name: Parameter.currency, value: cryptoCurrency.code)
            )
        }

        let request = retailRequestBuilder.get(
            path: Path.recurringBuyList,
            parameters: parameters,
            authenticated: true
        )!

        return retailNetworkAdapter.perform(request: request)
    }

    func fetchRecurringBuysWithRecurringBuyId(
        _ recurringBuyId: String
    ) -> AnyPublisher<[RecurringBuyResponse], NabuNetworkError> {
        let parameters: [URLQueryItem] = [
            URLQueryItem(name: Parameter.id, value: recurringBuyId)
        ]

        let request = retailRequestBuilder.get(
            path: Path.recurringBuyList,
            parameters: parameters,
            authenticated: true
        )!

        return retailNetworkAdapter.perform(request: request)
    }

    // MARK: - EligiblePaymentMethodRecurringBuyClientAPI

    func fetchEligiblePaymentMethodTypesStartingFromDate(
        _ date: Date?
    ) -> AnyPublisher<EligiblePaymentMethodsRecurringBuyResponse, NabuNetworkError> {
        var parameters: [URLQueryItem] = []
        if let date {
            parameters.append(
                URLQueryItem(
                    name: Parameter.date,
                    value: DateFormatter.iso8601Format.string(from: date)
                )
            )
        }

        let request = retailRequestBuilder.get(
            path: Path.recurringBuyNextPayment,
            parameters: parameters,
            authenticated: true
        )!

        return retailNetworkAdapter.perform(request: request)
    }
}
