// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureOpenBankingDomain
import Localization
import MoneyKit
import ToolKit

public struct LinkedBankData {
    public struct Partner: NewTypeString {
        public let value: String
        public init(_ value: String) { self.value = value }

        public static let yodlee: Self = "YODLEE"
        public static let yapily: Self = "YAPILY"
        public static let plaid: Self = "PLAID"
        public static let none: Self = "NONE"
    }

    public struct Account {
        public let name: String
        public let type: LinkedBankAccountType
        public let bankName: String
        public let routingNumber: String?
        public let sortCode: String?
        public let number: String

        init(response: LinkedBankResponse) {
            let accountNumber = (response.accountNumber?.replacingOccurrences(of: "x", with: "") ?? "")
            self.name = (response.accountName ?? response.name)
            self.type = LinkedBankAccountType(from: response.bankAccountType)
            self.bankName = response.name
            self.routingNumber = response.routingNumber
            self.sortCode = response.agentRef
            self.number = accountNumber
        }
    }

    public typealias LinkageError = LinkedBankResponse.Error

    public let currency: FiatCurrency
    public let identifier: String
    public let account: Account?
    let state: LinkedBankResponse.State
    public let error: LinkageError?
    public let errorCode: String?
    public let entity: String?
    public let paymentMethodType: PaymentMethodPayloadType
    public let partner: Partner
    public let icon: URL?
    public let logo: URL?
    public let isBankAccount: Bool
    public let isBankTransferAccount: Bool
    public let capabilities: Capabilities?

    public var topLimit: FiatValue

    public var isActive: Bool {
        state == .active
    }

    public var label: String {
        guard let account else {
            return identifier
        }
        return "\(account.bankName) \(account.type.title) \(account.number)"
    }

    init?(response: LinkedBankResponse) {
        self.identifier = response.id
        self.account = Account(response: response)
        self.state = response.state
        self.error = LinkageError(from: response.error)
        self.errorCode = response.errorCode
        self.entity = response.attributes?.entity
        self.paymentMethodType = response.isBankTransferAccount ? .bankTransfer : .bankAccount
        self.partner = Partner(response.partner)
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
        self.topLimit = .zero(currency: .USD)
        self.icon = (response.attributes?.media?.first(where: { $0.type == "icon" })?.source).flatMap(URL.init(string:))
        self.logo = (response.attributes?.media?.first(where: { $0.type == "logo" })?.source).flatMap(URL.init(string:))

        self.isBankAccount = response.isBankAccount
        self.isBankTransferAccount = response.isBankTransferAccount
        self.capabilities = response.capabilities
    }
}

extension LinkedBankData.LinkageError {
    init?(from error: LinkedBankResponse.Error?) {
        guard let error else { return nil }
        self = error
    }
}

extension LinkedBankData: Equatable {
    public static func == (lhs: LinkedBankData, rhs: LinkedBankData) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension OpenBanking.BankAccount {

    public init(_ linkedBankData: LinkedBankData) {
        self.init(
            id: .init(linkedBankData.identifier),
            partner: linkedBankData.partner.value,
            state: .init(linkedBankData.state.rawValue),
            currency: linkedBankData.currency.code,
            details: .init(
                bankAccountType: linkedBankData.account?.type.title,
                routingNumber: linkedBankData.account?.routingNumber,
                accountNumber: linkedBankData.account?.number,
                accountName: linkedBankData.account?.name,
                bankName: linkedBankData.account?.bankName,
                sortCode: linkedBankData.account?.sortCode
            ),
            error: linkedBankData.errorCode.map(OpenBanking.Error.code),
            attributes: .init(entity: linkedBankData.entity ?? "Safeconnect")
        )
    }
}
