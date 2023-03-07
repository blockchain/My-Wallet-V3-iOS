// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BigInt
import Errors
import FeatureCardPaymentDomain
import FeatureOpenBankingDomain
import Localization
import MoneyKit

/// `OrderDetails` is the primary model that should be accessed by
/// `Buy`, `Sell`, etc. It has an internal `value` of type `OrderDetailsValue`.
/// There is a `buy` and `sell` type.
public struct OrderDetails: Equatable {

    public typealias State = OrderDetailsState

    private enum OrderDetailsValue: Equatable {
        /// A `Buy` order
        case buy(BuyOrderDetails)

        /// A `Sell` order
        case sell(SellOrderDetails)

        var isBuy: Bool {
            switch self {
            case .buy:
                return true
            case .sell:
                return false
            }
        }

        var paymentMethodId: String? {
            switch self {
            case .buy(let buy):
                return buy.paymentMethodId
            case .sell:
                return nil
            }
        }

        mutating func set(paymentId: String?) {
            switch self {
            case .buy(var buy):
                buy.paymentMethodId = paymentId
                self = .buy(buy)
            case .sell:
                break
            }
        }
    }

    // MARK: - Properties

    public var paymentProccessorErrorOccurred: Bool {
        switch _value {
        case .buy(let details):
            return details.paymentProcessorErrorType != nil
        case .sell:
            return false
        }
    }

    public var isBuy: Bool {
        _value.isBuy
    }

    public var recurringBuyId: String? {
        switch _value {
        case .buy(let buy):
            return buy.recurringBuyId
        case .sell:
            return nil
        }
    }

    public var isSell: Bool {
        !isBuy
    }

    public var paymentMethod: PaymentMethod.MethodType {
        switch _value {
        case .buy(let buy):
            return buy.paymentMethod
        case .sell(let sell):
            return sell.paymentMethod
        }
    }

    public var creationDate: Date? {
        switch _value {
        case .buy(let buy):
            return buy.creationDate
        case .sell(let sell):
            return sell.creationDate
        }
    }

    /// The `MoneyValue` that you are submitting to the order
    public var inputValue: MoneyValue {
        switch _value {
        case .buy(let buy):
            return buy.fiatValue.moneyValue
        case .sell(let sell):
            return sell.cryptoValue.moneyValue
        }
    }

    /// The `MoneyValue` that you are receiving from the order
    public var outputValue: MoneyValue {
        switch _value {
        case .buy(let buy):
            return buy.cryptoValue.moneyValue
        case .sell(let sell):
            return sell.fiatValue.moneyValue
        }
    }

    public var price: MoneyValue? {
        switch _value {
        case .buy(let buy):
            return buy.price?.moneyValue
        case .sell(let sell):
            return sell.price?.moneyValue
        }
    }

    public var fee: MoneyValue? {
        switch _value {
        case .buy(let buy):
            return buy.fee?.moneyValue
        case .sell:
            return nil
        }
    }

    public var identifier: String {
        switch _value {
        case .buy(let buy):
            return buy.identifier
        case .sell(let sell):
            return sell.identifier
        }
    }

    public var paymentMethodId: String? {
        get {
            _value.paymentMethodId
        }
        set {
            _value.set(paymentId: newValue)
        }
    }

    public var authorizationData: PartnerAuthorizationData? {
        switch _value {
        case .buy(let buy):
            return buy.authorizationData
        case .sell:
            return nil
        }
    }

    public var state: State {
        switch _value {
        case .buy(let buy):
            return buy.state
        case .sell(let sell):
            return sell.state
        }
    }

    public var isNotAwaitingAction: Bool {
        !isAwaitingAction
    }

    public var isAwaitingAction: Bool {
        isPendingDepositBankWire || isPendingConfirmation || isPending3DSCardOrder
    }

    public var isBankWire: Bool {
        paymentMethodId == nil
    }

    public var isNotCancellable: Bool {
        !isCancellable
    }

    public var isCancellable: Bool {
        isPendingDepositBankWire || isPendingConfirmation
    }

    public var isPendingConfirmation: Bool {
        state == .pendingConfirmation
    }

    public var isPendingDepositBankWire: Bool {
        isPendingDeposit && isBankWire
    }

    public var isPendingDeposit: Bool {
        state == .pendingDeposit
    }

    public var isPending3DSCardOrder: Bool {
        guard let state = authorizationData?.state else { return false }
        return paymentMethodId != nil && state.isRequired
    }

    public var is3DSConfirmedCardOrder: Bool {
        guard let state = authorizationData?.state else { return false }
        return paymentMethodId != nil && state.isConfirmed
    }

    public var isFinal: Bool {
        switch state {
        case .cancelled, .failed, .expired, .finished:
            return true
        case .pendingDeposit, .pendingConfirmation, .depositMatched:
            return false
        }
    }

    public var needCvv: Bool {
        switch _value {
        case .buy(let details):
            return details.needCvv == true
        case .sell:
            return false
        }
    }

    public var error: String? {
        switch _value {
        case .buy(let details):
            return details.error
        case .sell(let details):
            return details.error
        }
    }

    public var ux: UX.Dialog? {
        switch _value {
        case .buy(let details):
            return details.ux
        case .sell(let details):
            return details.ux
        }
    }

    // MARK: - Private Properties

    private var _value: OrderDetailsValue

    // MARK: - Setup

    init?(recorder: AnalyticsEventRecorderAPI, response: OrderPayload.Response) {
        switch response.side {
        case .buy:
            guard let buy = BuyOrderDetails(recorder: recorder, response: response) else { return nil }
            self._value = .buy(buy)
        case .sell:
            guard let sell = SellOrderDetails(recorder: recorder, response: response) else { return nil }
            self._value = .sell(sell)
        }
    }
}

extension [OrderDetails] {
    var pendingDeposit: [OrderDetails] {
        filter { $0.state == .pendingDeposit }
    }
}

extension AnalyticsEvents {
    enum DebugEvent: AnalyticsEvent {
        case updatedAtParsingError(date: String)

        var name: String {
            switch self {
            case .updatedAtParsingError:
                return "updated_at_parsing_error"
            }
        }

        var params: [String: String]? {
            switch self {
            case .updatedAtParsingError(date: let date):
                return ["data": date]
            }
        }
    }
}

extension OpenBanking.Order {

    public init(_ order: OrderDetails) {
        self.init(
            id: .init(order.identifier),
            state: .init(order.state.rawValue),
            inputCurrency: order.inputValue.code,
            inputQuantity: order.inputValue.minorString,
            outputCurrency: order.outputValue.code,
            outputQuantity: order.outputValue.minorString,
            price: order.price?.minorString,
            paymentMethodId: order.paymentMethodId!,
            paymentType: order.paymentMethod.rawType.rawValue,
            attributes: .init()
        )
    }
}
