// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import OptionalSubscripts
import ToolKit
import WalletPayloadKit

final class Coincore: CoincoreAPI {

    private var storage = [String: BlockchainAccount].Store()

    // MARK: - Public Properties

    func account(_ identifier: String) -> AnyPublisher<BlockchainAccount?, Never> {
        Task.Publisher {
            if await !storage.contains(identifier),
               let currency = CoincoreHelper.currency(from: identifier, service: DIKit.resolve()),
               let asset = self[currency]
            {
                try? await storage.set(identifier, to: asset.defaultAccount.await())
            }
            return await storage.publisher(for: identifier)
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    func currency(_ identifier: String) -> CryptoCurrency? {
        CoincoreHelper.currency(from: identifier, service: DIKit.resolve())
    }

    func allAccounts(filter: AssetFilter) -> AnyPublisher<AccountGroup, CoincoreError> {
        reactiveWallet
            .waitUntilInitializedFirst
            .flatMap { [allAssets] _ -> AnyPublisher<[AccountGroup?], Never> in
                allAssets
                    .map { asset -> AnyPublisher<AccountGroup?, Never> in
                        asset
                            .accountGroup(filter: filter)
                    }
                    .zip()
            }
            .map { accountGroups -> [SingleAccount] in
                accountGroups
                    .compactMap { $0 }
                    .map(\.accounts)
                    .reduce(into: [SingleAccount]()) { result, accounts in
                        result.append(contentsOf: accounts)
                    }
            }
            .handleEvents(
                receiveOutput: { [storage] accounts in
                    Task {
                        await storage.transaction { storage in
                            for account in accounts {
                                await storage.set(account.identifier, to: account)
                            }
                        }
                    }
                }
            )
            .map { accounts -> AccountGroup? in
                AllAccountsGroup(accounts: accounts)
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
            .mapError()
    }

    let fiatAsset: Asset
    var allAssets: [Asset] {
        [fiatAsset] + cryptoAssets
    }

    var cryptoAssets: [CryptoAsset] {
        assetLoader.loadedAssets
    }

    // MARK: - Private Properties

    private let assetLoader: AssetLoaderAPI
    private let app: AppProtocol
    private let reactiveWallet: ReactiveWalletAPI
    private let delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI
    private let queue: DispatchQueue

    private var pkw: AnyCancellable?

    // MARK: - Setup

    init(
        app: AppProtocol,
        assetLoader: AssetLoaderAPI,
        fiatAsset: FiatAsset,
        reactiveWallet: ReactiveWalletAPI,
        delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI,
        queue: DispatchQueue
    ) {
        self.assetLoader = assetLoader
        self.fiatAsset = fiatAsset
        self.reactiveWallet = reactiveWallet
        self.delegatedCustodySubscriptionsService = delegatedCustodySubscriptionsService
        self.queue = queue
        self.app = app
        self.pkw = assetLoader.pkw.flatMap { [load] in load($0) }.subscribe()
    }

    func accounts(where isIncluded: @escaping (BlockchainAccount) -> Bool) -> AnyPublisher<[BlockchainAccount], Error> {
        accounts(filter: .allExcludingExchange, where: isIncluded)
    }

    func accounts(filter: AssetFilter, where isIncluded: @escaping (BlockchainAccount) -> Bool) -> AnyPublisher<[BlockchainAccount], Error> {
        allAccounts(filter: filter)
            .map(\.accounts)
            .map { accounts in
                accounts.filter(isIncluded) as [BlockchainAccount]
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    /// Gives a chance for all assets to initialize themselves.
    func initialize() -> AnyPublisher<Void, CoincoreError> {
        assetLoader
            .initAndPreload()
            .subscribe(on: queue)
            .receive(on: queue)
            .mapError(to: CoincoreError.self)
            .flatMap { [load, assetLoader] _ -> AnyPublisher<Void, CoincoreError> in
                load(assetLoader.loadedAssets)
            }
            .eraseToAnyPublisher()
    }

    func load(assets: [CryptoAsset]) -> AnyPublisher<Void, CoincoreError> {
        assets.map { asset -> AnyPublisher<Void, CoincoreError> in
            asset.initialize()
                .mapError { error in .failedToInitializeAsset(error: error) }
                .eraseToAnyPublisher()
        }
        .zip()
        .mapToVoid()
        .flatMap { [initializeDSC] _ in
            initializeDSC()
        }
        .flatMap { [initializeNonDSC] _ -> AnyPublisher<Void, CoincoreError> in
            initializeNonDSC(assets)
        }
        .eraseToAnyPublisher()
    }

    private func initializeDSC() -> AnyPublisher<Void, CoincoreError> {
        delegatedCustodySubscriptionsService
            .subscribe()
            .replaceError(with: ())
            .mapError()
            .eraseToAnyPublisher()
    }

    private func initializeNonDSC(assets: [CryptoAsset]) -> AnyPublisher<Void, CoincoreError> {
        assets
            .filter(\.asset.isCoin)
            .compactMap { $0 as? SubscriptionEntriesAsset }
            .map(\.subscriptionEntries)
            .zip()
            .map { groups -> [SubscriptionEntry] in
                groups.compactMap { $0 }.flatMap { $0 }
            }
            .flatMap { [delegatedCustodySubscriptionsService] entries in
                delegatedCustodySubscriptionsService.subscribeToNonDSCAccounts(accounts: entries)
            }
            .replaceError(with: ())
            .mapError()
            .eraseToAnyPublisher()
    }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? {
        assetLoader[cryptoCurrency]
    }

    /// We are looking for targets of our action.
    /// Action is considered what the source account wants to do.
    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError> {
        switch action {
        case .swap,
                .interestTransfer,
                .interestWithdraw,
                .stakingDeposit,
                .stakingWithdraw,
                .activeRewardsDeposit,
                .activeRewardsWithdraw:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return allAccounts(filter: .allExcludingExchange)
                .map(\.accounts)
                .map { accounts -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        Self.getActionFilter(
                            sourceAccount: cryptoAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
                .eraseToAnyPublisher()
        case .send:
            guard let cryptoAccount = sourceAccount as? CryptoAccount, let asset = self[cryptoAccount.asset] else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return asset
                .transactionTargets(account: cryptoAccount, action: action)
                .map { accounts -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        Self.getActionFilter(
                            sourceAccount: cryptoAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
                .mapError()
        case .buy:
            unimplemented("WIP")
        case .deposit,
                .receive,
                .sell,
                .sign,
                .viewActivity,
                .withdraw:
            unimplemented("\(action) is not supported.")
        }
    }

    private static func getActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        switch action {
        case .buy:
            unimplemented("WIP")
        case .stakingDeposit:
            return stakingDepositFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .stakingWithdraw:
            return stakingWithdrawFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .activeRewardsDeposit:
            return activeRewardsDepositFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .activeRewardsWithdraw:
            return activeRewardsWithdrawFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .interestTransfer:
            return interestTransferFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .interestWithdraw:
            return interestWithdrawFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .sell:
            return destinationAccount is FiatAccount
        case .swap:
            return swapActionFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .send:
            return sendActionFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .deposit,
                .receive,
                .sign,
                .viewActivity,
                .withdraw:
            return false
        }
    }

    private static func stakingDepositFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else { return false }
        return (sourceAccount is CryptoTradingAccount || sourceAccount is CryptoNonCustodialAccount)
        && destinationAccount is CryptoStakingAccount
    }

    private static func activeRewardsDepositFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else { return false }
        return (sourceAccount is CryptoTradingAccount || sourceAccount is CryptoNonCustodialAccount)
        && destinationAccount is CryptoActiveRewardsAccount
    }

    private static func activeRewardsWithdrawFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else { return false }
        return sourceAccount is CryptoActiveRewardsAccount && destinationAccount is CryptoTradingAccount
    }

    private static func interestTransferFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoTradingAccount, is CryptoInterestAccount),
            (is CryptoNonCustodialAccount, is CryptoInterestAccount):
            return true
        default:
            return false
        }
    }

    private static func interestWithdrawFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoInterestAccount, is CryptoTradingAccount),
            (is CryptoInterestAccount, is CryptoNonCustodialAccount):
            return true
        default:
            return false
        }
    }

    private static func stakingWithdrawFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoStakingAccount, is CryptoTradingAccount):
            return true
        default:
            return false
        }
    }

    private static func swapActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType != sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoTradingAccount, is CryptoTradingAccount),
            (is CryptoNonCustodialAccount, is CryptoTradingAccount),
            (is CryptoNonCustodialAccount, is CryptoNonCustodialAccount):
            return true
        default:
            return false
        }
    }

    private static func sendActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch destinationAccount {
        case is CryptoTradingAccount,
            is CryptoExchangeAccount,
            is CryptoNonCustodialAccount:
            return true
        default:
            return false
        }
    }
}

extension Dictionary.Store {

    nonisolated func nonisolated_publisher(
        for key: Key,
        bufferingPolicy limit: Dictionary.Store.BufferingPolicy = .bufferingNewest(1)
    ) -> AnyPublisher<Value?, Never> {
        Task.Publisher { await publisher(for: key, bufferingPolicy: limit) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func contains(_ key: Key) -> Bool {
        dictionary[key] != nil
    }
}
