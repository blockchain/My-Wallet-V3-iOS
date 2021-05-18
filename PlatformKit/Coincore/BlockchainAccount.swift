//
//  BlockchainAccount.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol TradingAccount { }

public protocol NonCustodialAccount { }

public protocol BlockchainAccount {
    var id: String { get }

    var label: String { get }

    var balance: Single<MoneyValue> { get }

    var pendingBalance: Single<MoneyValue> { get }

    var actions: Single<AvailableActions> { get }

    var isFunded: Single<Bool> { get }

    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue>
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
                account.can(perform: action)
                    .catchError { error -> Single<BlockchainAccount?> in
                        onError?(account)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }

            return Single.zip(elements)
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
                account.can(perform: action)
                    .map { $0 as? Element.Element }
                    .catchError { error -> Single<SingleAccount?> in
                        onError?(account)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }
            return Single.zip(elements)
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

extension BlockchainAccount {
    /// Emits `self` if it can perform the given action, otherwise emit `nil`.
    fileprivate func can(perform action: AssetAction) -> Single<BlockchainAccount?> {
        actions.map { actions in
            actions.contains(action) ? self : nil
        }
    }
}
