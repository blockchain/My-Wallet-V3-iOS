// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Localization
import MoneyKit
import RxSwift
import ToolKit

public protocol CryptoAsset: Asset {

    var asset: CryptoCurrency { get }

    /// Gives a chance for the `CryptoAsset` to initialize itself.
    func initialize() -> AnyPublisher<Void, AssetError>

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> { get }

    var subscriptionEntries: AnyPublisher<[SubscriptionEntry], Never> { get }

    var canTransactToCustodial: AnyPublisher<Bool, Never> { get }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

extension CryptoAsset {

    public var subscriptionEntries: AnyPublisher<[SubscriptionEntry], Never> { .just([]) }

    /// Forces wallets with the previous legacy label to the new default label.
    public func upgradeLegacyLabels(accounts: [BlockchainAccount]) -> AnyPublisher<Void, Never> {
        let publishers: [AnyPublisher<Void, Never>] = accounts
            // Optional cast each element in the array to `CryptoNonCustodialAccount`.
            .compactMap { $0 as? CryptoNonCustodialAccount }
            // Filter in elements that need `labelNeedsForcedUpdate`.
            .filter(\.labelNeedsForcedUpdate)
            // Map to infallible Publisher jobs.
            .map { account in
                // Updates this account label with new default.
                account.updateLabel(account.newForcedUpdateLabel)
            }

        return Deferred {
            publishers
                .merge()
                .collect()
        }
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    /// Possible transaction targets this `Asset` has for a transaction initiating from the given `SingleAccount`.
    public func transactionTargets(
        account: SingleAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], Never> {
        guard let crypto = account as? CryptoAccount else {
            fatalError("Expected a CryptoAccount: \(account).")
        }
        guard crypto.asset == asset else {
            fatalError("Expected asset to be the same.")
        }
        switch crypto {
        case is CryptoTradingAccount,
             is NonCustodialAccount:
            return canTransactToCustodial
                .flatMap { [accountGroup] canTransactToCustodial -> AnyPublisher<AccountGroup?, Never> in
                    accountGroup(canTransactToCustodial ? action.allFilterType : .nonCustodial)
                }
                .compactMap { $0 }
                .map(\.accounts)
                .mapFilter(excluding: crypto.identifier)
                .eraseToAnyPublisher()
        default:
            unimplemented()
        }
    }
}

extension AssetAction {
    fileprivate var allFilterType: AssetFilter {
        switch self {
        case .send:
            return .all
        case .buy,
                .deposit,
                .interestTransfer,
                .interestWithdraw,
                .stakingDeposit,
                .receive,
                .sell,
                .sign,
                .swap,
                .viewActivity,
                .withdraw:
            return .allExcludingExchange
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
