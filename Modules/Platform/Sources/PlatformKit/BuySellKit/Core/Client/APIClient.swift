// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import MoneyKit
import NetworkKit

typealias SimpleBuyClientAPI = EligibilityClientAPI &
    SupportedPairsClientAPI &
    TradingPairsClientAPI &
    OrderDetailsClientAPI &
    OrderCancellationClientAPI &
    PaymentAccountClientAPI &
    OrderCreationClientAPI &
    CardOrderConfirmationClientAPI &
    QuoteClientAPI &
    BeneficiariesClientAPI &
    OrdersActivityClientAPI &
    WithdrawalClientAPI &
    PaymentEligibleMethodsClientAPI &
    LinkedBanksClientAPI &
    ApplePayClientAPI

/// Simple-Buy network client
final class APIClient: SimpleBuyClientAPI {

    // MARK: - Types

    fileprivate enum Parameter {
        static let product = "product"
        static let currency = "currency"
        static let fiatCurrency = "fiatCurrency"
        static let currencyPair = "currencyPair"
        static let pendingOnly = "pendingOnly"
        static let action = "action"
        static let amount = "amount"
        static let methods = "methods"
        static let checkEligibility = "checkEligibility"
        static let states = "states"
        static let benefiary = "beneficiary"
        static let eligibleOnly = "eligibleOnly"
        static let paymentMethod = "paymentMethod"
    }

    private enum Path {
        static let accumulatedTrades = ["trades", "accumulated"]
        static let transactions = ["payments", "transactions"]
        static let paymentMethods = ["payments", "methods"]
        static let eligiblePaymentMethods = ["eligible", "payment-methods"]
        static let applePayInfo = ["payments", "apple-pay", "info"]
        static let paymentsCardAcquirers = ["payments", "card-acquirers"]
        static let beneficiaries = ["payments", "beneficiaries"]
        static let banks = ["payments", "banks"]
        static let supportedPairs = ["simple-buy", "pairs"]
        static let tradingPairs = ["custodial", "trades", "pairs"]
        static let trades = ["simple-buy", "trades"]
        static let paymentAccount = ["payments", "accounts", "simplebuy"]
        static let quote = ["brokerage", "quote"]
        static let eligible = ["simple-buy", "eligible"]
        static let withdrawalLocks = ["payments", "withdrawals", "locks"]
        static let withdrawalLocksCheck = ["payments", "withdrawals", "locks", "check"]
        static let withdrawalFees = ["payments", "withdrawals", "fees"]
        static let withdrawal = ["payments", "withdrawals"]
        static let bankTransfer = ["payments", "banktransfer"]
        static let linkedBanks = ["payments", "banking-info"]

        static func updateLinkedBank(id: String) -> [String] {
            bankTransfer + [id, "update"]
        }
    }

    private enum Constants {
        static let bankTransfer = "BANK_TRANSFER"
        static let simpleBuyProduct = "SIMPLEBUY"
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - BeneficiariesClientAPI

    var beneficiaries: AnyPublisher<[BeneficiaryResponse], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.beneficiaries,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func deleteBank(by id: String) -> AnyPublisher<Void, NabuNetworkError> {
        let path = Path.banks + [id]
        let request = requestBuilder.delete(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - EligibilityClientAPI

    func isEligible(
        for currency: String,
        methods: [String]
    ) -> AnyPublisher<EligibilityResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.fiatCurrency,
                value: currency
            ),
            URLQueryItem(
                name: Parameter.methods,
                value: methods.joined(separator: ",")
            )
        ]
        let request = requestBuilder.get(
            path: Path.eligible,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - OrderCancellationClientAPI

    func cancel(order id: String) -> AnyPublisher<Void, NabuNetworkError> {
        let request = requestBuilder.delete(
            path: Path.trades + [id],
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - SupportedPairsClientAPI

    /// Streams the supported Simple-Buy pairs
    func supportedPairs(
        with option: SupportedPairsFilterOption
    ) -> AnyPublisher<SupportedPairsResponse, NabuNetworkError> {
        let queryParameters: [URLQueryItem]
        switch option {
        case .all:
            queryParameters = []
        case .only(fiatCurrency: let currency):
            queryParameters = [
                URLQueryItem(
                    name: Parameter.currency,
                    value: currency.rawValue
                )
            ]
        }
        let request = requestBuilder.get(
            path: Path.supportedPairs,
            parameters: queryParameters
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - TradingPairsClientAPI

    func tradingPairs() -> AnyPublisher<[String], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.tradingPairs,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - OrdersActivityClientAPI

    func activityResponse(
        currency: Currency
    ) -> AnyPublisher<OrdersActivityResponse, NabuNetworkError> {
        let path = Path.transactions
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.code
            ),
            URLQueryItem(
                name: Parameter.product,
                value: Constants.simpleBuyProduct
            )
        ]
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - OrderDetailsClientAPI

    func fetchAccumulatedTradeAmounts() -> AnyPublisher<[AccumulatedTradeDetails], NabuNetworkError> {

        struct Response: Decodable {

            struct RawDetails: Decodable {

                struct Amount: Decodable {
                    let symbol: String
                    let value: String
                }

                let amount: MoneyValue
                let period: AccumulatedTradeDetails.TimePeriod

                enum CodingKeys: String, CodingKey {
                    case amount
                    case period = "termType"
                }

                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    let rawAmount = try values.decode(Amount.self, forKey: .amount)
                    self.amount = try (
                        MoneyValue.create(
                            major: rawAmount.value,
                            currency: CurrencyType(code: rawAmount.symbol)
                        )
                    ) ?? .zero(currency: CurrencyType(code: rawAmount.symbol))
                    self.period = try values.decode(AccumulatedTradeDetails.TimePeriod.self, forKey: .period)
                }
            }

            let tradesAccumulated: [RawDetails]
        }

        let parameters = [
            URLQueryItem(
                name: "products",
                value: "SIMPLEBUY"
            )
        ]
        let request = requestBuilder.get(
            path: Path.accumulatedTrades,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .perform(request: request, responseType: Response.self)
            .map(\.tradesAccumulated)
            .map { rawTradeDetailsList -> [AccumulatedTradeDetails] in
                rawTradeDetailsList.map {
                    AccumulatedTradeDetails(
                        amount: $0.amount,
                        period: $0.period
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func orderDetails(
        pendingOnly: Bool
    ) -> AnyPublisher<[OrderPayload.Response], NabuNetworkError> {
        let path = Path.trades
        let states: [OrderDetails.State] = OrderDetails.State.allCases.filter { $0 != .cancelled }
        let parameters = [
            URLQueryItem(
                name: Parameter.pendingOnly,
                value: pendingOnly ? "true" : "false"
            ),
            URLQueryItem(
                name: Parameter.states,
                value: states.map(\.rawValue).joined(separator: ",")
            )
        ]
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func orderDetails(
        with identifier: String
    ) -> AnyPublisher<OrderPayload.Response, NabuNetworkError> {
        let path = Path.trades + [identifier]
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - PaymentAccountClientAPI

    func paymentAccount(
        for currency: FiatCurrency
    ) -> AnyPublisher<PlatformKit.PaymentAccount.Response, NabuNetworkError> {
        struct Payload: Encodable {
            let currency: String
        }

        let payload = Payload(currency: currency.code)
        let request = requestBuilder.put(
            path: Path.paymentAccount,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - OrderCreationClientAPI

    func create(
        order: OrderPayload.Request,
        createPendingOrder: Bool
    ) -> AnyPublisher<OrderPayload.Response, NabuNetworkError> {
        var parameters: [URLQueryItem] = []
        if createPendingOrder {
            parameters.append(
                URLQueryItem(
                    name: Parameter.action,
                    value: OrderPayload.CreateActionType.pending.rawValue
                )
            )
        }

        let path = Path.trades
        let request = requestBuilder.post(
            path: path,
            parameters: parameters,
            body: try? order.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - CardOrderConfirmationClientAPI

    func confirmOrder(
        with identifier: String,
        partner: OrderPayload.ConfirmOrder.Partner,
        paymentMethodId: String?
    ) -> AnyPublisher<OrderPayload.Response, NabuNetworkError> {
        let payload = OrderPayload.ConfirmOrder(
            partner: partner,
            action: .confirm,
            paymentMethodId: paymentMethodId
        )
        let path = Path.trades + [identifier]
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func getQuote(queryRequest: QuoteQueryRequest) -> AnyPublisher<QuoteResponse, NabuNetworkError> {
        let path = Path.quote
        let request = requestBuilder.post(
            path: path,
            body: try? queryRequest.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - PaymentEligibleMethodsClientAPI

    func eligiblePaymentMethods(
        for currency: String,
        currentTier: KYC.Tier
    ) -> AnyPublisher<[PaymentMethodsResponse.Method], NabuNetworkError> {
        var queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency
            ),
            URLQueryItem(
                name: Parameter.eligibleOnly,
                value: "\(currentTier == .verified)"
            )
        ]

        let request = requestBuilder.get(
            path: Path.eligiblePaymentMethods,
            parameters: queryParameters,
            authenticated: true
        )!

        return networkAdapter.perform(request: request)
    }

    func paymentsCardAcquirers() -> AnyPublisher<[PaymentCardAcquirer], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.paymentsCardAcquirers,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - ApplePayInfoClientAPI

    func applePayInfo(
        for currency: String
    ) -> AnyPublisher<ApplePayInfo, NabuNetworkError> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency
            )
        ]
        let request = requestBuilder.get(
            path: Path.applePayInfo,
            parameters: queryParameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - WithdrawalClientAPI

    func withdrawalLocksCheck(
        currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> AnyPublisher<WithdrawalLocksCheckResponse, NabuNetworkError> {
        struct Payload: Encodable {
            let paymentMethod: String
            let currency: String
        }
        let request = requestBuilder.post(
            path: Path.withdrawalLocksCheck,
            body: try? Payload(paymentMethod: paymentMethodType.rawValue, currency: currency.code).encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func withdrawalLocks(
        currency: FiatCurrency
    ) -> AnyPublisher<WithdrawalLocksResponse, NabuNetworkError> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.withdrawalLocks,
            parameters: queryParameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func withdrawFee(
        currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> AnyPublisher<WithdrawFeesResponse, NabuNetworkError> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.code
            ),
            URLQueryItem(
                name: Parameter.product,
                value: Constants.simpleBuyProduct
            ),
            URLQueryItem(
                name: Parameter.paymentMethod,
                value: paymentMethodType.rawValue
            )
        ]
        let request = requestBuilder.get(
            path: Path.withdrawalFees,
            parameters: queryParameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func withdraw(
        data: WithdrawalCheckoutData
    ) -> AnyPublisher<WithdrawalCheckoutResponse, NabuNetworkError> {
        let payload = WithdrawalPayload(data: data)
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let request = requestBuilder.post(
            path: Path.withdrawal,
            body: try? payload.encode(),
            headers: headers,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - LinkedBanks API

    func linkedBanks() -> AnyPublisher<[LinkedBankResponse], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.linkedBanks,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func deleteLinkedBank(
        for id: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let request = requestBuilder.delete(
            path: Path.bankTransfer + [id],
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func createBankLinkage(
        for currency: FiatCurrency
    ) -> AnyPublisher<CreateBankLinkageResponse, NabuNetworkError> {
        struct Payload: Encodable {
            let currency: String
        }
        let payload = Payload(currency: currency.code)
        let request = requestBuilder.post(
            path: Path.bankTransfer,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func getLinkedBank(
        for id: String
    ) -> AnyPublisher<LinkedBankResponse, NabuNetworkError> {
        let path = Path.linkedBanks + [id]
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    func updateBankLinkage(
        for id: String,
        providerAccountId: String,
        accountId: String
    ) -> AnyPublisher<LinkedBankResponse, NabuNetworkError> {
        struct Payload: Encodable {
            struct Attributes: Encodable {
                let providerAccountId: String
                let accountId: String
            }

            let attributes: Attributes
        }
        let path = Path.updateLinkedBank(id: id)
        let payload = Payload(attributes: .init(providerAccountId: providerAccountId, accountId: accountId))
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
