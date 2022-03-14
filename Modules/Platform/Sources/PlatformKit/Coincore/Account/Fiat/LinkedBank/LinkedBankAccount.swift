// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

public class LinkedBankAccount: FiatAccount, BankAccount {

    // MARK: - BlockchainAccount

    public let isDefault: Bool = false

    public var actions: Single<AvailableActions> {
        .just(.init())
    }

    public var actionableBalance: Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }

    public var sourceState: Single<SourceState> {
        .just(.canTransact)
    }

    public var canWithdrawFunds: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        .just(
            BankAccountReceiveAddress(
                address: accountId,
                label: label,
                currencyType: currencyType
            )
        )
    }

    public var balance: Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }

    public var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }

    public var isFunded: Single<Bool> {
        .just(false)
    }

    public var activity: Single<[ActivityItemEvent]> {
        .just([])
    }

    public func invalidateAccountBalance() {
        // no-op
    }

    public let fiatCurrency: FiatCurrency
    public private(set) lazy var identifier: AnyHashable = "LinkedBankAccount.\(accountId).\(accountNumber).\(paymentType)"

    public let label: String
    public let accountId: String
    public let accountNumber: String
    public let accountType: LinkedBankAccountType
    public let paymentType: PaymentMethodPayloadType
    public let partner: LinkedBankData.Partner
    public let data: LinkedBankData

    // MARK: - Init

    public init(
        label: String,
        accountNumber: String,
        accountId: String,
        accountType: LinkedBankAccountType,
        currency: FiatCurrency,
        paymentType: PaymentMethodPayloadType,
        partner: LinkedBankData.Partner,
        data: LinkedBankData
    ) {
        self.label = label
        self.accountId = accountId
        self.accountType = accountType
        self.accountNumber = accountNumber
        fiatCurrency = currency
        self.paymentType = paymentType
        self.partner = partner
        self.data = data
    }

    // MARK: - BlockchainAccount

    public func balancePair(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValuePair, Error> {
        .just(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currencyType))
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }
}
