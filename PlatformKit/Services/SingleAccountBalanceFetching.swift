//
//  SingleAccountBalanceFetching.swift
//  PlatformKit
//
//  Created by Daniel Huri on 12/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

// MARK: - Base Protocol

/// This protocol defines a single responsibility requirement for an account balance fetching
public protocol SingleAccountBalanceFetching: AnyObject {
    var accountType: SingleAccountType { get }
    var pendingBalanceMoney: Single<MoneyValue> { get }
    var balanceMoney: Single<MoneyValue> { get }
    var pendingBalanceMoneyObservable: Observable<MoneyValue> { get }
    var balanceMoneyObservable: Observable<MoneyValue> { get }
    var balanceFetchTriggerRelay: PublishRelay<Void> { get }
}

// MARK: - Crypto Protocol

public protocol CryptoAccountBalanceFetching: SingleAccountBalanceFetching {
    var balance: Single<CryptoValue> { get }
}

extension CryptoAccountBalanceFetching {
    public var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
}

// MARK: - Fiat Protocol

public protocol FiatAccountBalanceFetching: SingleAccountBalanceFetching {
    var balance: Single<FiatValue> { get }
}

extension FiatAccountBalanceFetching {
    public var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
}

public protocol CustodialAccountBalanceFetching: SingleAccountBalanceFetching {
    /// Indicates, based on the data provided by the API, if the user has funded this account in the past.
    var isFunded: Observable<Bool> { get }
    
    /// Returns the funds state
    var fundsState: Observable<AccountBalanceState<CustodialAccountBalance>> { get }

    /// Streams  the withdrawable amount, based on the dat provided by the API
    var withdrawableObservable: Observable<MoneyValue> { get }

    /// Single result of the withdrawable amount, based on the dat provided by the API.
    var withdrawableMoney: Single<MoneyValue> { get }
}

/// AccountBalanceFetching implementation representing a absent account.
public final class AbsentAccountBalanceFetching: CustodialAccountBalanceFetching {

    public let accountType: SingleAccountType
    
    public var pendingBalanceMoney: Single<MoneyValue> {
        pendingBalanceMoneyObservable
            .take(1)
            .asSingle()
    }
    
    public var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceRelay
            .asObservable()
    }

    public var balanceMoney: Single<MoneyValue> {
        balanceMoneyObservable
            .take(1)
            .asSingle()
    }
    
    public var balanceMoneyObservable: Observable<MoneyValue> {
        balanceRelay
            .asObservable()
    }

    public var withdrawableObservable: Observable<MoneyValue> {
        withdrawableRelay
            .asObservable()
    }

    public var withdrawableMoney: Single<MoneyValue> {
        withdrawableObservable
            .take(1)
            .asSingle()
    }
    
    public var isFunded: Observable<Bool> {
        .just(false)
    }
    
    public var fundsState: Observable<AccountBalanceState<CustodialAccountBalance>> {
        .just(.absent)
    }

    public let balanceFetchTriggerRelay: PublishRelay<Void> = .init()
    private let balanceRelay: BehaviorRelay<MoneyValue>
    private let pendingBalanceRelay: BehaviorRelay<MoneyValue>
    private let withdrawableRelay: BehaviorRelay<MoneyValue>

    public init(currencyType: CurrencyType, accountType: SingleAccountType) {
        switch accountType {
        case .custodial:
            pendingBalanceRelay = BehaviorRelay(value: .zero(currency: currencyType))
            balanceRelay = BehaviorRelay(value: .zero(currency: currencyType))
            withdrawableRelay = BehaviorRelay(value: .zero(currency: currencyType))
        case .nonCustodial:
            guard let currency = currencyType.cryptoCurrency else { fatalError("Expected a CryptoCurrency: \(currencyType)") }
            pendingBalanceRelay = BehaviorRelay(value: .zero(currency: currency))
            balanceRelay = BehaviorRelay(value: .zero(currency: currency))
            withdrawableRelay = BehaviorRelay(value: .zero(currency: currencyType))
        }
        self.accountType = accountType
    }
}
