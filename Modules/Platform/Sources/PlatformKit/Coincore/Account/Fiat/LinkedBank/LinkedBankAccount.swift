// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import ToolKit

public class LinkedBankAccount: FiatAccount, BankAccount, FiatAccountCapabilities {

    // MARK: - BlockchainAccount

    public let accountType: AccountType = .external
    public let isDefault: Bool = false

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: fiatCurrency))
    }

    public var capabilities: Capabilities? {
        data.capabilities
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(
            BankAccountReceiveAddress(
                address: accountId,
                label: label,
                assetName: assetName,
                currencyType: currencyType
            )
        )
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: fiatCurrency))
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: fiatCurrency))
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        .just(false)
    }

    public let fiatCurrency: FiatCurrency
    public private(set) lazy var identifier: String = "LinkedBankAccount.\(accountId).\(accountNumber).\(paymentType)"

    public let label: String
    public var assetName: String
    public let accountId: String
    public let accountNumber: String
    public let bankAccountType: LinkedBankAccountType
    public let paymentType: PaymentMethodPayloadType
    public let partner: LinkedBankData.Partner
    public let data: LinkedBankData

    // MARK: - Init

    public init(
        label: String,
        accountNumber: String,
        accountId: String,
        bankAccountType: LinkedBankAccountType,
        currency: FiatCurrency,
        paymentType: PaymentMethodPayloadType,
        partner: LinkedBankData.Partner,
        data: LinkedBankData
    ) {
        self.label = label
        self.assetName = ""
        self.accountId = accountId
        self.bankAccountType = bankAccountType
        self.accountNumber = accountNumber
        self.fiatCurrency = currency
        self.paymentType = paymentType
        self.partner = partner
        self.data = data
    }

    // MARK: - BlockchainAccount

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        .just(false)
    }

    public func invalidateAccountBalance() {
        // no-op
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        .just(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currencyType))
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        .just(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currencyType))
    }
}
