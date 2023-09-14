// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import MoneyKit
import PlatformKit
import UIComponentsKit

extension PaymentMethod {

    public var logoResource: ImageLocation {
        switch type {
        case .card:
            return .local(name: "icon-card", bundle: .platformUIKit)

        case .applePay:
            return .local(name: "icon-applepay", bundle: .platformUIKit)

        case .bankAccount, .bankTransfer:
            return .local(name: "icon-bank", bundle: .platformUIKit)

        case .funds(let currency):
            return currency.logoResource
        }
    }
}

extension PaymentMethodAccount {

    public var logoResource: ImageLocation {
        switch paymentMethodType {
        case .card(let cardData):
            return cardData.type.thumbnail ?? .local(name: "icon-card", bundle: .platformUIKit)

        case .applePay:
            return .local(name: "icon-applepay", bundle: .platformUIKit)

        case .linkedBank(let data):
            return data.icon.map(ImageLocation.remote(url:)) ?? .local(name: "icon-bank", bundle: .platformUIKit)

        case .account(let fundData):
            return fundData.balance.currency.logoResource

        case .suggested(let paymentMethod):
            return paymentMethod.logoResource
        }
    }

    // This extension overrides the default implementation of `BlockchainAccount`
    public var logoBackgroundColor: UIColor {
        switch paymentMethodType {
        case .account:
            return .fiat

        case .card:
            return .background

        case .suggested(let paymentMethod):
            guard !paymentMethod.type.isApplePay else {
                return .clear
            }
            return .background

        case .linkedBank,
             .applePay:
            return .clear
        }
    }
}
