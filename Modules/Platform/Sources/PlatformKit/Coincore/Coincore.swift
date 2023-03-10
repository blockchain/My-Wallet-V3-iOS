// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import RxSwift
import ToolKit
import WalletPayloadKit

public enum CoincoreError: Error, Equatable {
    case failedToInitializeAsset(error: AssetError)
}

/// Types adopting the `CoincoreAPI` should provide a way to retrieve fiat and crypto accounts
public protocol CoincoreAPI {

    /// Provides access to fiat and crypto custodial and non custodial assets.
    func allAccounts(filter: AssetFilter) -> AnyPublisher<AccountGroup, CoincoreError>
    func account(
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
}

final class Coincore: CoincoreAPI {

    // MARK: - Public Properties

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

    func account(where isIncluded: @escaping (BlockchainAccount) -> Bool) -> AnyPublisher<[BlockchainAccount], Error> {
        allAccounts(filter: .allExcludingExchange)
            .map(\.accounts)
            .map { accounts in
                accounts.filter(isIncluded)
            }
            .map { accounts in
                accounts as [BlockchainAccount]
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
