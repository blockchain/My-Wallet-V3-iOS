//
//  AccountGroup.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

/// A `BlockchainAccount` that represents a collection of accounts, opposed to a single account.
public protocol AccountGroup: BlockchainAccount {
    var accounts: [SingleAccount] { get }

    func includes(account: BlockchainAccount) -> Bool
}

extension AccountGroup {
    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        let balances: [Single<MoneyValue>] = accounts
            .map { account in
                account
                    .fiatBalance(fiatCurrency: fiatCurrency)
                    .catchErrorJustReturn(.zero(currency: fiatCurrency))
            }
        return Single.zip(balances)
            .map { moneyValues -> MoneyValue in
                try moneyValues.reduce(into: MoneyValue.zero(currency: fiatCurrency)) { (result, this) in
                    try result += this
                }
            }
    }

    public func includes(account: BlockchainAccount) -> Bool {
        accounts.map(\.id).contains(account.id)
    }

    public var actions: Single<AvailableActions> {
        Single.zip(accounts.map(\.actions))
            .map { actions -> AvailableActions in
                actions.reduce(into: AvailableActions()) { $0.formUnion($1) }
            }
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        Single
            .just(accounts.map({ $0.can(perform: action) }))
            .flatMapConcatFirst()
    }
}

public enum AccountGroupError: Error {
    case noBalance
}
