// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Extensions
import Localization
import PlatformKit
import RxSwift
import ToolKit
import WalletPayloadKit

public enum BitcoinCashWalletRepositoryError: Error {
    case missingWallet
    case failedToFetchAccount(Error)
}

final class BitcoinCashWalletAccountRepository {

    private struct Key: Hashable {}

    struct BCHAccounts: Equatable {
        let defaultAccount: BitcoinCashWalletAccount
        let accounts: [BitcoinCashWalletAccount]

        let entry: BitcoinCashEntry?
        var txNotes: [String: String]? {
            entry?.txNotes
        }
    }

    // MARK: - Properties

    let defaultAccount: AnyPublisher<BitcoinCashWalletAccount, BitcoinCashWalletRepositoryError>
    let accounts: AnyPublisher<[BitcoinCashWalletAccount], BitcoinCashWalletRepositoryError>
    let activeAccounts: AnyPublisher<[BitcoinCashWalletAccount], BitcoinCashWalletRepositoryError>
    let bitcoinCashEntry: AnyPublisher<BitcoinCashEntry?, BitcoinCashWalletRepositoryError>

    private let bitcoinCashFetcher: BitcoinCashEntryFetcherAPI
    private let cachedValue: CachedValueNew<
        Key,
        BCHAccounts,
        BitcoinCashWalletRepositoryError
    >

    // MARK: - Init

    init(
        bitcoinCashFetcher: BitcoinCashEntryFetcherAPI = resolve()
    ) {
        self.bitcoinCashFetcher = bitcoinCashFetcher

        let cache: AnyCache<Key, BCHAccounts> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [bitcoinCashFetcher] _ in
                bitcoinCashFetcher.fetchOrCreateBitcoinCash()
                    .mapError { _ in .missingWallet }
                    .map { entry in
                        let defaultAccount = bchWalletAccount(from: entry.defaultAccount)
                        let accounts = entry.accounts.map(bchWalletAccount(from:))
                        return BCHAccounts(defaultAccount: defaultAccount, accounts: accounts, entry: entry)
                    }
                    .eraseToAnyPublisher()
            }
        )

        self.defaultAccount = cachedValue.get(key: Key())
            .map(\.defaultAccount)
            .eraseToAnyPublisher()

        self.accounts = cachedValue.get(key: Key())
            .map(\.accounts)
            .eraseToAnyPublisher()

        self.activeAccounts = accounts
            .map { accounts in
                accounts.filter(\.isActive)
            }
            .eraseToAnyPublisher()

        self.bitcoinCashEntry = cachedValue.get(key: Key())
            .map(\.entry)
            .eraseToAnyPublisher()
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }

    func update(accountIndex: Int, label: String) -> AnyPublisher<Void, Never> {
        bitcoinCashEntry
            .catch { _ -> AnyPublisher<BitcoinCashEntry?, Never> in
                .just(nil)
            }
            .flatMap { [bitcoinCashFetcher] entry -> AnyPublisher<Void, Never> in
                guard let entry else {
                    return .just(())
                }
                let account = entry.accounts.first(where: { $0.index == accountIndex })
                if let updatedAccount = account?.updateLabel(label) {
                    var accounts = entry.accounts
                    accounts[accountIndex] = updatedAccount
                    let updatedEntry = BitcoinCashEntry(payload: entry.payload, accounts: accounts, txNotes: entry.txNotes)
                    return bitcoinCashFetcher.update(entry: updatedEntry)
                        .catch { _ in .noValue }
                        .mapError(to: Never.self)
                        .mapToVoid()
                        .eraseToAnyPublisher()
                }
                return .just(())
            }
            .handleEvents(
                receiveOutput: { [cachedValue] _ in
                    cachedValue.invalidateCache()
                }
            )
            .eraseToAnyPublisher()
    }

    /// Batch updates of account labels
    /// Note the label is infered from the property `newForcedUpdateLabel` of protocol `CryptoNonCustodialAccount`
    /// - Parameter accounts: An array of `BitcoinChainCryptoAccount` to be updated
    /// - Returns: `AnyPublisher<Void, Never>`
    func updateLabels(on accounts: [BitcoinChainCryptoAccount]) -> AnyPublisher<Void, Never> {
        bitcoinCashEntry
            .catch { _ -> AnyPublisher<BitcoinCashEntry?, Never> in
                .just(nil)
            }
            .flatMap { [bitcoinCashFetcher] entry -> AnyPublisher<Void, Never> in
                guard let entry else {
                    return .just(())
                }
                let updatedAccounts = entry.accounts.map { entry in
                    if let label = accounts.first(where: { $0.hdAccountIndex == entry.index })?.newForcedUpdateLabel {
                        return entry.updateLabel(label)
                    } else {
                        return entry
                    }
                }
                let updatedEntry = BitcoinCashEntry(payload: entry.payload, accounts: updatedAccounts, txNotes: entry.txNotes)
                return bitcoinCashFetcher.update(entry: updatedEntry)
                    .catch { _ in .noValue }
                    .mapError(to: Never.self)
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .handleEvents(
                receiveOutput: { [cachedValue] _ in
                    cachedValue.invalidateCache()
                }
            )
            .eraseToAnyPublisher()
    }
}

private func bchWalletAccount(
    from entry: BitcoinCashEntry.AccountEntry
) -> BitcoinCashWalletAccount {
    BitcoinCashWalletAccount(
        index: entry.index,
        publicKey: entry.publicKey,
        label: entry.label ?? defaultLabel(using: entry.index),
        derivationType: derivationType(from: entry.derivationType),
        archived: entry.archived
    )
}

private func defaultLabel(using index: Int) -> String {
    let suffix = index > 0 ? "\(index)" : ""
    return "\(NonLocalizedConstants.defiWalletTitle) \(suffix)"
}

extension BitcoinCashWalletAccount {
    var isActive: Bool {
        !archived
    }
}
