//
//  CustodialMoneyBalanceFetcher.swift
//  PlatformKit
//
//  Created by Daniel on 07/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public final class CustodialMoneyBalanceFetcher: CustodialAccountBalanceFetching {

    // MARK: - Public Properties
    
    public var accountType: SingleAccountType {
        _ = setup
        return .custodial(fetcher.custodialAccountType)
    }
    
    public var pendingBalanceMoney: Single<MoneyValue> {
        pendingBalanceMoneyObservable
            .take(1)
            .asSingle()
    }
    
    public var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        _ = setup
        let currencyType = self.currencyType
        return balanceRelay
            .map { $0?.pending }
            .map { $0 ?? .zero(currency: currencyType) }
    }
    
    public var balanceMoney: Single<MoneyValue> {
        balanceMoneyObservable
            .take(1)
            .asSingle()
    }
     
    public var balanceMoneyObservable: Observable<MoneyValue> {
        _ = setup
        let currencyType = self.currencyType
        return balanceRelay
            .map { $0?.available }
            .map { $0 ?? .zero(currency: currencyType) }
    }

    public var withdrawableObservable: Observable<MoneyValue> {
        _ = setup
        let currencyType = self.currencyType
        return balanceRelay
            .map { $0?.withdrawable }
            .map { $0 ?? .zero(currency: currencyType) }
    }

    public var withdrawableMoney: Single<MoneyValue> {
        withdrawableObservable
            .take(1)
            .asSingle()
    }

    public var isFunded: Observable<Bool> {
        fundsState.map { $0 != .absent }
    }
    
    public var fundsState: Observable<AccountBalanceState<CustodialAccountBalance>> {
        _ = setup
        return balanceRelay
            .map { balance -> AccountBalanceState<CustodialAccountBalance> in
                guard let balance = balance else {
                    return .absent
                }
                return .present(balance)
            }
    }

    public var balanceFetchTriggerRelay: PublishRelay<Void> {
        _ = setup
        return fetcher.balanceFetchTriggerRelay
    }

    // MARK: - Private Properties
    private let balanceRelay: BehaviorRelay<CustodialAccountBalance?>
    private let currencyType: CurrencyType
    private let disposeBag = DisposeBag()
    private let fetcher: CustodialBalanceStatesFetcherAPI
    
    private lazy var setup: Void = {
        let currencyType = self.currencyType
        fetcher.balanceStatesObservable
            .map { $0[currencyType].balance }
            .catchErrorJustReturn(nil)
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: Init

    public init(currencyType: CurrencyType,
                fetcher: CustodialBalanceStatesFetcherAPI) {
        self.balanceRelay = BehaviorRelay(value: nil)
        self.fetcher = fetcher
        self.currencyType = currencyType
    }
}
