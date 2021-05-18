//
//  Coincore.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public final class Coincore {
    
    // MARK: - Public Properties

    public var allAccounts: Single<AccountGroup> {
        reactiveWallet.waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) in
                Single.zip(
                    self.allAssets.map { asset in asset.accountGroup(filter: .all) }
                )
            }
            .map { accountGroups -> [SingleAccount] in
                accountGroups.map { $0.accounts }.reduce([SingleAccount](), +)
            }
            .map { accounts -> AccountGroup in
                AllAccountsGroup(accounts: accounts)
            }
    }
    
    // MARK: - Private Properties

    private var allAssets: [Asset] {
        [fiatAsset] + sortedCryptoAssets
    }
    
    private var sortedCryptoAssets: [CryptoAsset] {
        cryptoAssets.sorted(by: { $0.key < $1.key }).map { $0.value }
    }
    
    private let cryptoAssets: [CryptoCurrency: CryptoAsset]
    private let fiatAsset: FiatAsset
    private let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup

    init(cryptoAssets: [CryptoCurrency: CryptoAsset],
         fiatAsset: FiatAsset = FiatAsset(),
         reactiveWallet: ReactiveWalletAPI = resolve()) {
        self.cryptoAssets = cryptoAssets
        self.fiatAsset = fiatAsset
        self.reactiveWallet = reactiveWallet
    }

    /// Gives a chance for all assets to initialize themselves.
    public func initialize() -> Completable {
        var completables = cryptoAssets
            .values
            .map { asset -> Completable in
                asset.initialize()
            }
        completables.append(fiatAsset.initialize())
        return Completable.concat(completables)
    }

    public subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? {
        guard let asset = cryptoAssets[cryptoCurrency] else {
            fatalError("Unknown crypto currency.")
        }
        return asset
    }

    /// We are looking for targets of our action.
    /// Action is considered what the source account wants to do.
    public func getTransactionTargets(
        sourceAccount: CryptoAccount,
        action: AssetAction
    ) -> Single<[SingleAccount]> {
        let crypto = cryptoAssets.map { $0.value }
        guard let sourceAsset = crypto.filter({ $0.asset == sourceAccount.asset }).first else {
            fatalError("CryptoAsset unavailable for sourceAccount: \(sourceAccount)")
        }
        
        let sameCurrencyTransactionTargets = sourceAsset.transactionTargets(account: sourceAccount)
        let fiatTargets = fiatAsset
            .accountGroup(filter: .all)
            .map(\.accounts)
        
        let sameCurrencyPlusFiat = Single.zip(
            sameCurrencyTransactionTargets,
            fiatTargets
        )
        
        switch action {
        case .swap,
             .send:
            return allAccounts
                .map(\.accounts)
                .flatMap { accounts -> Single<[SingleAccount]> in
                    if action == .send {
                        return sameCurrencyPlusFiat.map { $0.0 + $0.1 }
                    } else {
                        return .just(accounts)
                    }
                }
                .map(weak: self) { (self, accounts) -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        self.getActionFilter(
                            sourceAccount: sourceAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            unimplemented()
        }
    }

    private func getActionFilter(sourceAccount: CryptoAccount, destinationAccount: SingleAccount, action: AssetAction) -> Bool {
        switch action {
        case .sell:
            return destinationAccount is FiatAccount
        case .swap:
            return destinationAccount is CryptoAccount
                && destinationAccount.currencyType != sourceAccount.currencyType
                && !(destinationAccount is FiatAccount)
                && !(destinationAccount is CryptoInterestAccount)
                && (sourceAccount is TradingAccount ? destinationAccount is TradingAccount : true)
        case .send:
            return !(destinationAccount is FiatAccount)
        case .deposit,
             .receive,
             .viewActivity,
             .withdraw:
            return false
        }
    }
}
