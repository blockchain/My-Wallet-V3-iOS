// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import OptionalSubscripts
import ToolKit
import WalletPayloadKit

public enum CoincoreError: Error, Equatable {
    case failedToInitializeAsset(error: AssetError)
}

/// Types adopting the `CoincoreAPI` should provide a way to retrieve fiat and crypto accounts
public protocol CoincoreAPI {

    /// Provides access to fiat and crypto custodial and non custodial assets.
    func allAccounts(filter: AssetFilter) -> AnyPublisher<AccountGroup, CoincoreError>

    func accounts(
        filter: AssetFilter,
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error>

    func accounts(
        where isIncluded: @escaping (BlockchainAccount) -> Bool
    ) -> AnyPublisher<[BlockchainAccount], Error>

    var allAssets: [Asset] { get }
    var fiatAsset: Asset { get }
    var cryptoAssets: [CryptoAsset] { get }

    /// Initialize any assets prior being available
    func initialize() -> AnyPublisher<Void, CoincoreError>

    /// Provides an array of `SingleAccount` instances for the specified source account and the given action.
    /// - Parameters:
    ///   - sourceAccount: A `BlockchainAccount` to be used as the source account
    ///   - action: An `AssetAction` to determine the transaction targets.
    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError>

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset { get }

    func account(_ identifier: AnyHashable) -> AnyPublisher<BlockchainAccount?, Never>
}

final class Coincore: CoincoreAPI {

    private var storage = [AnyHashable: BlockchainAccount].Store()

    // MARK: - Public Properties

    func account(_ identifier: AnyHashable) -> AnyPublisher<BlockchainAccount?, Never> {
        storage.nonisolated_publisher(for: identifier)
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

    private let assetLoader: AssetLoader
    private let app: AppProtocol
    private let reactiveWallet: ReactiveWalletAPI
    private let delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI
    private let queue: DispatchQueue

    private var pkw: AnyCancellable?

    // MARK: - Setup

    init(
        app: AppProtocol,
        assetLoader: AssetLoader,
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
        .flatMap { [shouldInitializeNonDSC, initializeNonDSC] _ -> AnyPublisher<Void, CoincoreError> in
            shouldInitializeNonDSC()
                .mapError(to: CoincoreError.self)
                .flatMap { isEnabled -> AnyPublisher<Void, CoincoreError> in
                    isEnabled ? initializeNonDSC(assets) : .just(())
                }
                .eraseToAnyPublisher()
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

    private func shouldInitializeNonDSC() -> AnyPublisher<Bool, Never> {
        let coincoreFlag = app
            .publisher(
                for: blockchain.app.configuration.unified.balance.coincore.is.enabled,
                as: Bool.self
            )
            .prefix(1)
            .map { $0.value ?? false }
            .replaceError(with: false)
            .handleEvents(
                receiveOutput: { [app] isEnabled in
                    Task {
                        try await app.set(
                            blockchain.app.configuration.unified.balance.coincore.is.setup,
                            to: isEnabled
                        )
                    }
                }
            )
        let superappV1Flag = app
            .publisher(
                for: blockchain.app.configuration.app.superapp.v1.is.enabled,
                as: Bool.self
            )
            .prefix(1)
            .map { $0.value ?? false }
            .replaceError(with: false)
        return coincoreFlag
            .zip(superappV1Flag)
            .map { $0 || $1 }
            .eraseToAnyPublisher()
    }

    private func initializeNonDSC(assets: [CryptoAsset]) -> AnyPublisher<Void, CoincoreError> {
        assets
            .filter(\.asset.isCoin)
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

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
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
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return self[cryptoAccount.asset]
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

extension CoincoreAPI {

    public func fiatAccount(for currency: FiatCurrency, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) -> FiatCustodialAccount? {
        let accounts = enabledCurrenciesService.allEnabledFiatCurrencies.set
        guard accounts.contains(currency) else { return nil }
        return FiatCustodialAccount(fiatCurrency: currency)
    }

    public func cryptoTradingAccount(for currency: CryptoCurrency) -> CryptoTradingAccount? {
        guard currency.supports(product: .custodialWalletBalance) else { return nil }
        return CryptoTradingAccount(asset: currency, cryptoReceiveAddressFactory: self[currency].addressFactory)
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension EnvironmentValues {

    public var coincore: any CoincoreAPI {
        get { self[CoincoreAPIEnvironmentKey.self] }
        set { self[CoincoreAPIEnvironmentKey.self] = newValue }
    }
}

struct CoincoreAPIEnvironmentKey: EnvironmentKey {
    static let defaultValue: any CoincoreAPI = resolve()
}
#endif

public final class CoincoreNAPI {

    let app: AppProtocol
    let coincore: CoincoreAPI

    public init(_ app: AppProtocol = resolve(), _ coincore: CoincoreAPI = resolve()) {
        self.app = app
        self.coincore = coincore
    }

    public func register() async throws {

        func filter(_ filter: AssetFilter) -> AnyPublisher<AnyJSON, Never> {
            coincore.allAccounts(filter: filter)
                .map { group in AnyJSON(group.accounts.map(\.identifier)) }
                .replaceError(with: .empty)
                .eraseToAnyPublisher()
        }

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.filter.accounts,
            repository: { tag in
                do {
                    return try filter(tag.context.decode(blockchain.coin.core.filter.id))
                } catch {
                    return .just(.empty)
                }
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.all,
            repository: { _ in filter(.all) }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.custodial.all,
            repository: { _ in filter(.custodial) }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.DeFi.all,
            repository: { _ in filter(.nonCustodial) }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.interest.all,
            repository: { _ in filter(.interest) }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.staking.all,
            repository: { _ in filter(.staking) }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.active.rewards.all,
            repository: { _ in filter(.activeRewards) }
        )

        func filter(_ filter: AssetFilter, _ id: AnyHashable?) -> AnyPublisher<AnyJSON, Never> {
            coincore.accounts(filter: filter, where: { account in account.currencyType.code == id })
                .replaceError(with: [])
                .map { accounts in AnyJSON(accounts.map(\.identifier)) }
                .eraseToAnyPublisher()
        }

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.custodial.asset,
            repository: { tag in
                filter(.custodial, tag[blockchain.coin.core.accounts.custodial.asset.id])
                    .map { json in AnyJSON(json.array()?.first) } // custodial only have a single associated acount per asset
                    .eraseToAnyPublisher()
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.DeFi.asset,
            repository: { tag in
                filter(.nonCustodial, tag[blockchain.coin.core.accounts.DeFi.asset.id])
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.interest.asset,
            repository: { tag in
                filter(.interest, tag[blockchain.coin.core.accounts.interest.asset.id])
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.staking.asset,
            repository: { tag in
                filter(.staking, tag[blockchain.coin.core.accounts.staking.asset.id])
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.active.rewards.asset,
            repository: { tag in
                filter(.activeRewards, tag[blockchain.coin.core.accounts.active.rewards.asset.id])
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.accounts.custodial.with.balance,
            repository: { [app, coincore] _ -> AnyPublisher<AnyJSON, Never> in
                coincore.allAccounts(filter: .custodial)
                    .combineLatest(
                        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
                            .compactMap(\.value)
                            .setFailureType(to: CoincoreError.self)
                    )
                    .map { group, currency -> AnyPublisher<AnyJSON, Never> in
                        group.accounts.map { account -> AnyPublisher<(BlockchainAccount, MoneyValue), Never> in
                            account.fiatBalance(fiatCurrency: currency)
                                .replaceError(with: .zero(currency: currency))
                                .map { balance in (account, balance) }
                                .eraseToAnyPublisher()
                        }
                        .combineLatest()
                        .map { each -> AnyJSON in
                            do {
                                return try AnyJSON(
                                    each
                                        .filter { _, balance in balance.isPositive && balance.isNotDust }
                                        .sorted { l, r in try l.1 > r.1 }
                                        .map(\.0.identifier)
                                )
                            } catch {
                                return .empty
                            }
                        }
                        .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
            }
        )

        func account(_ tag: Tag.Reference) throws -> AnyPublisher<BlockchainAccount, Never> {
            try coincore.account(tag.context[blockchain.coin.core.account.id].or(throw: "No account id")).compacted()
                .eraseToAnyPublisher()
        }

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyJSON in
                        var json = L_blockchain_coin_core_account.JSON()
                        json.label = account.label
                        json.currency = account.currencyType.code
                        return json.toJSON()
                    }
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )

        var refresh = L_blockchain_namespace_napi_napi_policy.JSON()

        refresh.invalidate.on = [
            blockchain.ux.home.event.did.pull.to.refresh[],
            blockchain.ux.transaction.event.execution.status.completed[]
        ]

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account.balance.total,
            policy: refresh,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyPublisher<AnyJSON, Error> in
                        account.balance.map { balance in AnyJSON(try? balance.encode().json()) }
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account.balance.pending,
            policy: refresh,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyPublisher<AnyJSON, Error> in
                        account.pendingBalance.map { balance in AnyJSON(try? balance.encode().json()) }
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account.balance.available,
            policy: refresh,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyPublisher<AnyJSON, Error> in
                        account.actionableBalance.map { balance in AnyJSON(try? balance.encode().json()) }
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account.is.funded,
            policy: refresh,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyPublisher<AnyJSON, Error> in
                        account.isFunded.map { isFunded in AnyJSON(isFunded) }
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account.can.perform,
            policy: refresh,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyPublisher<AnyJSON, Error> in
                        account.can(perform: .buy)
                            .combineLatest(account.can(perform: .sell), account.can(perform: .swap)).map { buy, sell, swap -> AnyJSON in
                                var perform = L_blockchain_coin_core_account_can_perform.JSON()
                                perform.buy = buy
                                perform.sell = sell
                                perform.swap = swap
                                return perform.toJSON()
                            }
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )

        try await app.register(
            napi: blockchain.coin.core,
            domain: blockchain.coin.core.account.receive.address,
            repository: { tag in
                do {
                    return try account(tag).map { account -> AnyPublisher<AnyJSON, Error> in
                        account.receiveAddress.map { receiveAddress -> AnyJSON in
                            var receive = L_blockchain_coin_core_account_receive.JSON()
                            receive.address = receiveAddress.address
                            receive.memo = receiveAddress.memo
                            return receive.toJSON()
                        }
                        .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return .just(.empty)
                }
            }
        )
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
}
