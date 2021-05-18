//
//  BlockchainAccount.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public typealias AvailableActions = Set<AssetAction>

public protocol TradingAccount { }

public protocol NonCustodialAccount { }

public protocol BlockchainAccount {

    /// This account ID.
    ///
    /// This may be an internal ID, a public key, or something else.
    var id: String { get }

    /// This account label.
    var label: String { get }

    /// The total balance on this account.
    var balance: Single<MoneyValue> { get }

    /// The pending balance of this account.
    var pendingBalance: Single<MoneyValue> { get }

    /// Emits `Set` containing all actions this account can execute.
    var actions: Single<AvailableActions> { get }

    /// Indicates if this account is funded.
    ///
    /// Depending of the account implementation, this may not strictly mean a positive balance.
    /// Some accounts may be set as `isFunded` if they have ever had a positive balance in the past.
    var isFunded: Single<Bool> { get }

    /// The balance of this account exchanged to the given fiat currency.
    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue>

    /// Checks if this account can execute the given action.
    func can(perform action: AssetAction) -> Single<Bool>
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == Array<BlockchainAccount> {
    /// Filters an `[BlockchainAccount]` for only `BlockchainAccount`s that can perform the given action.
    /// - parameter failSequence: When `true` rethrows errors raised by any `BlockchainAccount.can(perform:)`. If this is set to `false`, filters out from the emitted element any account whose `BlockchainAccount.can(perform:)` failed.
    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool = true,
        onError: ((BlockchainAccount) -> Void)? = nil
    ) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<BlockchainAccount?>] = accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .catchError { error -> Single<BlockchainAccount?> in
                        onError?(account)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }

            return Single.zip(elements)
                // Filter nil elements (accounts that can't perform action)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == Array<SingleAccount> {
    /// Filters an `[SingleAccount]` for only `SingleAccount`s that can perform the given action.
    /// - parameter failSequence: When `true` rethrows errors raised by any `BlockchainAccount.can(perform:)`. If this is set to `false`, filters out from the emitted element any account whose `BlockchainAccount.can(perform:)` failed.
    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool = true,
        onError: ((SingleAccount) -> Void)? = nil
    ) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<SingleAccount?>] = accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .catchError { error -> Single<SingleAccount?> in
                        onError?(account)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }
            return Single.zip(elements)
                // Filter nil elements (accounts that can't perform action)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
    
    public func flatMapFilter(excluding identifier: String) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<SingleAccount?>] = accounts.map { account in
                let value = account.id != identifier ? account : nil
                return Single.just(value)
            }
            return Single.zip(elements)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
}
