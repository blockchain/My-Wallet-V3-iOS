//
//  CryptoAsset.swift
//  PlatformKit
//
//  Created by Paulo on 29/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxSwift
import ToolKit

public protocol CryptoAsset: Asset {
    var asset: CryptoCurrency { get }
    var defaultAccount: Single<SingleAccount> { get }
}

extension CryptoAsset {
    public func initialize() -> Completable {
        .empty()
    }

    /// Forces wallets with the previous legacy label to the new default label.
    public func upgradeLegacyLabels(accounts: [BlockchainAccount]) -> Completable {
        Single.just(accounts)
            // Optional cast each element in the array to `CryptoNonCustodialAccount`.
            .map { $0.compactMap { $0 as? CryptoNonCustodialAccount } }
            // Filter in elements that need `labelNeedsForcedUpdate`.
            .map { $0.filter(\.labelNeedsForcedUpdate) }
            // Map to infallible Completable jobs.
            .map { accounts -> [Completable] in
                accounts.map {
                    // Updates this account label with new default.
                    $0.updateLabel($0.newForcedUpdateLabel)
                        .onErrorComplete()
                }
            }
            // Concat.
            .flatMapCompletable { completables -> Completable in
                .concat(completables)
            }
    }

    /// Possible transaction targets this `Asset` has for a transaction initiating from the given `SingleAccount`.
    public func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]> {
        guard let crypto = account as? CryptoAccount else {
            fatalError("Expected a CryptoAccount: \(account)")
        }
        precondition(crypto.asset == asset)
        // TODO: Fetch exchange accounts
        switch crypto {
        case is CryptoTradingAccount:
            return accountGroup(filter: .nonCustodial)
                .map(\.accounts)
        case is CryptoNonCustodialAccount:
            return accountGroup(filter: .all)
                .map(\.accounts)
                .flatMapFilter(excluding: crypto.id)
        default:
            unimplemented()
        }
    }
}

extension CryptoNonCustodialAccount {

    /// Replaces the part of this wallet label that matches the previous default wallet label with the new default label.
    /// To be used only during the forced wallet label update.
    fileprivate var newForcedUpdateLabel: String {
        guard let legacyLabel = asset.legacyLabel else {
            return label
        }
        return label.replacingOccurrences(of: legacyLabel, with: asset.defaultWalletName)
    }

    /// If this account label need to be updated to the new default label.
    /// To be used only during the forced wallet label update.
    fileprivate var labelNeedsForcedUpdate: Bool {
        guard let legacyLabel = asset.legacyLabel else {
            return false
        }
        return label.contains(legacyLabel)
    }
}

extension CryptoCurrency {

    /// The default label for this asset, it may not be a localized string.
    /// To be used only during the forced wallet label update.
    fileprivate var legacyLabel: String? {
        switch self {
        case .bitcoin:
            return LocalizationConstants.Account.legacyMyBitcoinWallet
        case .bitcoinCash:
            // Legacy BCH label is not localized.
            return "My Bitcoin Cash Wallet"
        case .ethereum:
            // Legacy ETH label is not localized.
            return "My Ether Wallet"
        case .stellar:
            // Legacy XLM label is not localized.
            return "My Stellar Wallet"
        default:
            // Any other existing or future asset does not need forced wallet name upgrade.
            return nil
        }
    }
}
