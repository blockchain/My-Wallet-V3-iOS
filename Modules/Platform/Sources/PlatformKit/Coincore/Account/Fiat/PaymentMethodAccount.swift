// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

// swiftformat:disable all

/// A type that represents a payment method as a `BlockchainAccount`.
public final class PaymentMethodAccount: FiatAccount {

    public let paymentMethodType: PaymentMethodType
    public let paymentMethod: PaymentMethod
    public let priceService: PriceServiceAPI
    public let accountType: AccountType

    public init(
        paymentMethodType: PaymentMethodType,
        paymentMethod: PaymentMethod,
        priceService: PriceServiceAPI = resolve()
    ) {
        self.paymentMethodType = paymentMethodType
        self.paymentMethod = paymentMethod
        self.priceService = priceService
        accountType = paymentMethod.isCustodial ? .trading : .nonCustodial
    }

    public let isDefault: Bool = false

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        .just([]) // no activity to report
    }

    public var fiatCurrency: FiatCurrency {
        guard let fiatCurrency = paymentMethodType.currency.fiatCurrency else {
            impossible("Payment Method Accounts should always be denominated in fiat.")
        }
        return fiatCurrency
    }

    public var capabilities: Capabilities? { nil }

    public var identifier: AnyHashable {
        paymentMethodType.id
    }

    public var label: String {
        paymentMethodType.label
    }

    public var assetName: String {
        ""
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        .just(true)
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        .just(paymentMethodType.balance)
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error>{
        .just(action == .buy)
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func invalidateAccountBalance() {
        // NO-OP
    }
}
