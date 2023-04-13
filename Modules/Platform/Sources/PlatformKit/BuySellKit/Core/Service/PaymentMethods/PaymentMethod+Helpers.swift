// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import MoneyKit

extension PaymentMethod {
    init?(currency: String, method: PaymentMethodsResponse.Method, supportedFiatCurrencies: [FiatCurrency]) {
        // Preferrably use the payment method's currency
        let rawCurrency = method.currency ?? currency
        guard let currency = FiatCurrency(code: rawCurrency) else {
            return nil
        }

        // Make sure the take exists
        guard let rawType = PaymentMethodPayloadType(rawValue: method.type) else {
            return nil
        }

        guard let methodType = MethodType(
            type: rawType,
            subTypes: method.subTypes,
            currency: currency,
            supportedFiatCurrencies: supportedFiatCurrencies
        ) else {
            return nil
        }
        let zero: FiatValue = .zero(currency: currency)
        let minValue = method.limits?.min ?? "0"
        let maxValue = method.limits?.max ?? "500000"
        let maxDailyValue = method.limits?.daily?.available ?? maxValue
        let maxAnnualValue = method.limits?.annual?.available ?? maxValue
        let min = FiatValue.create(minor: minValue, currency: currency) ?? zero
        let max = FiatValue.create(minor: maxValue, currency: currency) ?? zero
        let maxDaily = FiatValue.create(minor: maxDailyValue, currency: currency)
        let maxAnnual = FiatValue.create(minor: maxAnnualValue, currency: currency)
        self.init(
            type: methodType,
            max: max,
            min: min,
            maxDaily: maxDaily,
            maxAnnual: maxAnnual,
            isEligible: method.eligible,
            isVisible: method.visible,
            capabilities: method.capabilities?.map(Capability.init(_:))
        )
    }
}

extension PaymentMethod.MethodType {
    public var analyticsParameter: AnalyticsEvents.SimpleBuy.PaymentMethod {
        switch self {
        case .card:
            return .card
        case .bankAccount, .bankTransfer:
            return .bank
        case .funds:
            return .funds
        case .applePay:
            return .applePay
        }
    }
}

extension [PaymentMethod] {
    init(response: PaymentMethodsResponse, supportedFiatCurrencies: [FiatCurrency]) {
        self.init()
        let methods = response.methods
            .compactMap {
                PaymentMethod(
                    currency: response.currency,
                    method: $0,
                    supportedFiatCurrencies: supportedFiatCurrencies
                )
            }
        append(contentsOf: methods)
    }

    init(
        methods: [PaymentMethodsResponse.Method],
        currency: FiatCurrency,
        supportedFiatCurrencies: [FiatCurrency],
        enableApplePay: Bool
    ) {
        self.init()

        if enableApplePay,
           let card = methods.first(where: { $0.applePayEligible }),
           let applePayPaymentMethod = PaymentMethod(
               currency: currency.code,
               method: .init(
                   type: PaymentMethodPayloadType.applePay.rawValue,
                   limits: card.limits,
                   subTypes: card.subTypes,
                   currency: card.currency,
                   eligible: card.eligible,
                   visible: card.visible,
                   mobilePayment: card.mobilePayment,
                   capabilities: nil
               ),
               supportedFiatCurrencies: supportedFiatCurrencies
           )
        {
            append(applePayPaymentMethod)
        }

        let methods = methods
            .compactMap {
                PaymentMethod(
                    currency: currency.code,
                    method: $0,
                    supportedFiatCurrencies: supportedFiatCurrencies
                )
            }

        append(contentsOf: methods)
    }

    public var funds: [PaymentMethod] {
        filter(\.type.isFunds)
    }

    public var fundsCurrencies: [CurrencyType] {
        compactMap { method in
            switch method.type {
            case .funds(let currency):
                return currency
            default:
                return nil
            }
        }
    }
}
