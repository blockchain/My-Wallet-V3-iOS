// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

typealias L10n = LocalizationConstants.LineItem.Transactional

struct PaymentAccountUSD: PaymentAccountDescribing, Equatable {
    var fields: [PaymentAccountProperty.Field] {
        [
            .field(
                name: L10n.referenceID,
                value: address,
                copy: true
            ),
            .bankName(bankName),
            .recipientName(recipientName),
            .bankCode(bankCode),
            .accountNumber(accountNumber),
            .routingNumber(routingNumber)
        ]
    }

    static let currency: FiatCurrency = .USD
    let identifier: String
    let address: String
    let state: PaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let bankName: String
    let bankCountry: String
    let bankCode: String
    let accountNumber: String
    let routingNumber: String
    let recipientName: String

    init?(response: PaymentAccount) {
        guard response.isNotBIND else { return nil }
        guard response.currency == Self.currency else { return nil }
        guard
            let accountNumber: String = response.agent.account,
            let recipientName: String = response.agent.recipient,
            let routingNumber: String = response.agent.routingNumber,
            let name: String = response.agent.name,
            let country: String = response.agent.country,
            let code: String = response.agent.code
        else { return nil }
        self.routingNumber = routingNumber
        self.accountNumber = accountNumber
        self.recipientName = recipientName
        self.bankCountry = country
        self.bankName = name
        self.bankCode = code
        self.identifier = response.id
        self.state = response.state
        self.address = response.address
    }
}

struct PaymentAccountUSDBIND: PaymentAccountDescribing, Equatable {

    var fields: [PaymentAccountProperty.Field] {
        [
            .field(
                name: L10n.alias,
                value: label,
                help: L10n.aliasHelp,
                copy: true
            ),
            .field(
                name: L10n.accountHolder,
                value: name
            ),
            .field(
                name: L10n.accountType,
                value: accountType
            ),
            .field(
                name: L10n.CBU,
                value: address
            ),
            .field(
                name: L10n.accountNumber,
                value: code
            ),
            .recipientName(recipientName)
        ]
    }

    static let currency: FiatCurrency = .USD
    let identifier: String
    let state: PaymentAccountProperty.State
    let currency: FiatCurrency = Self.currency
    let name: String
    let code: String
    let recipientName: String
    let label: String
    let accountType: String
    let address: String

    init?(response: PaymentAccount) {
        guard response.isBIND else { return nil }
        guard response.currency == My.currency else { return nil }
        guard
            let accountType: String = response.agent.accountType,
            let code: String = response.agent.code,
            let label: String = response.agent.label,
            let name: String = response.agent.name,
            let recipientName: String = response.agent.recipient
        else { return nil }
        self.accountType = accountType
        self.label = label
        self.name = name
        self.recipientName = recipientName
        self.code = code
        self.address = response.address
        self.identifier = response.id
        self.state = response.state
    }
}

extension PaymentAccount {
    var isBIND: Bool { partner == "BIND" }
    var isNotBIND: Bool { !isBIND }
}
