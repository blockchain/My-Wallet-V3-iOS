// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents {
    public enum FiatWithdrawal: AnalyticsEvent {
        case formShown
        case confirm(currencyCode: String, amount: String)
        case checkout(CheckoutFormEvent)
        case withdrawSuccess(currencyCode: String)
        case withdrawFailure(currencyCode: String)

        public enum CheckoutFormEvent {
            case shown(currencyCode: String)
            case confirm(currencyCode: String)
            case cancel(currencyCode: String)

            var name: String {
                switch self {
                case .shown:
                    "cash_withdraw_checkout_shown"
                case .confirm:
                    "cash_withdraw_checkout_confirm"
                case .cancel:
                    "cash_withdraw_checkout_cancel"
                }
            }
        }

        public var name: String {
            switch self {
            case .formShown:
                "cash_withdraw_form_shown"
            case .confirm:
                "cash_witdraw_form_confirm_click"
            case .checkout(let value):
                value.name
            case .withdrawSuccess:
                "cash_withdraw_success"
            case .withdrawFailure:
                "cash_withdraw_error"
            }
        }

        public var params: [String: String]? {
            switch self {
            case .formShown:
                nil
            case .confirm(let currencyCode, let amount):
                ["currency": currencyCode, "amount": amount]
            case .checkout(let value):
                switch value {
                case .shown(let currencyCode),
                     .cancel(let currencyCode),
                     .confirm(let currencyCode):
                    ["currency": currencyCode]
                }
            case .withdrawFailure(let currencyCode),
                 .withdrawSuccess(let currencyCode):
                ["currency": currencyCode]
            }
        }
    }
}
