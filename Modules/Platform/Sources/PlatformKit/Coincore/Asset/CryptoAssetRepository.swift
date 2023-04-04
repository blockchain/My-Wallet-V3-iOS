// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Localization
import MoneyKit
import RxSwift
import ToolKit

public protocol CryptoAssetRepositoryAPI {

    var nonCustodialGroup: AnyPublisher<AccountGroup?, Never> { get }

    var canTransactToCustodial: AnyPublisher<Bool, Never> { get }

    func accountGroup(
        filter: AssetFilter
    ) -> AnyPublisher<AccountGroup?, Never>

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never>

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

public final class CryptoAssetRepository: CryptoAssetRepositoryAPI {

    // MARK: - Types

    public typealias NonCustodialAccountsProvider = () -> AnyPublisher<[SingleAccount], CryptoAssetError>

    public typealias ExchangeAccountProvider = () -> AnyPublisher<CryptoExchangeAccount?, Never>

    // MARK: - Properties

    public var nonCustodialGroup: AnyPublisher<AccountGroup?, Never> {
        nonCustodialAccountsProvider()
            .map(AllAccountsGroup.init(accounts:))
            .recordErrors(on: errorRecorder)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    public var canTransactToCustodial: AnyPublisher<Bool, Never> {
        kycTiersService.tiers
            .map { tiers in
                tiers.isVerifiedApproved
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private let app: AppProtocol
    private let asset: CryptoCurrency
    private let errorRecorder: ErrorRecording
    private let kycTiersService: KYCTiersServiceAPI
    private let nonCustodialAccountsProvider: NonCustodialAccountsProvider
    private let exchangeAccountsProvider: ExchangeAccountsProviderAPI
    private let addressFactory: ExternalAssetAddressFactory
    private let featureFlag: FeatureFetching

    // MARK: - Setup

    public init(
        app: AppProtocol = resolve(),
        asset: CryptoCurrency,
        errorRecorder: ErrorRecording,
        kycTiersService: KYCTiersServiceAPI,
        nonCustodialAccountsProvider: @escaping NonCustodialAccountsProvider,
        exchangeAccountsProvider: ExchangeAccountsProviderAPI,
        addressFactory: ExternalAssetAddressFactory,
        featureFlag: FeatureFetching
    ) {
        self.app = app
        self.asset = asset
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.nonCustodialAccountsProvider = nonCustodialAccountsProvider
        self.exchangeAccountsProvider = exchangeAccountsProvider
        self.addressFactory = addressFactory
        self.featureFlag = featureFlag
    }

    // MARK: - Public methods

    /// For each option in the `filter: AssetFilter` option set, we will gather the correct accounts and add to the result AllAccountsGroup.
    public func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {

        var stream: [AnyPublisher<[SingleAccount], Never>] = []

        if filter.contains(.custodial) {
            stream.append(custodialAccounts)
        }

        if filter.contains(.interest) {
            stream.append(interestAccounts)
        }

        if filter.contains(.nonCustodial) {
            let publisher: AnyPublisher<[SingleAccount], Never> = nonCustodialAccountsProvider()
                .recordErrors(on: errorRecorder)
                .replaceError(with: [])
                .eraseToAnyPublisher()
            stream.append(publisher)
        }

        if filter.contains(.staking) {
            stream.append(stakingAccounts)
        }

        if filter.contains(.exchange) {
            stream.append(exchangeAccounts)
        }

        if filter.contains(.activeRewards) {
            stream.append(activeRewardsAccounts)
        }

        return stream
            .combineLatest()
            .map { accounts in AllAccountsGroup(accounts: accounts.flatMap { $0 }) }
            .eraseToAnyPublisher()
    }

    public func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        let receiveAddress = try? parse(
            address: address,
            label: address,
            onTxCompleted: { _ in .empty() }
        )
            .get()
        return .just(receiveAddress)
    }

    public func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        addressFactory.makeExternalAssetAddress(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }

    private var stakingAccounts: AnyPublisher<[SingleAccount], Never> {
        guard asset.supports(product: .stakingBalance) else {
            return .just([])
        }
        return app
            .publisher(for: blockchain.app.configuration.staking.is.enabled, as: Bool.self)
            .replaceError(with: false)
            .map { [asset, addressFactory] isEnabled -> [SingleAccount] in
                guard isEnabled else {
                    return []
                }
                let account = CryptoStakingAccount(
                    asset: asset,
                    cryptoReceiveAddressFactory: addressFactory
                ) as SingleAccount
                return [account]
            }
            .eraseToAnyPublisher()
    }

    private var activeRewardsAccounts: AnyPublisher<[SingleAccount], Never> {
        guard asset.supports(product: .activeRewardsBalance) else {
            return .just([])
        }
        return app
            .publisher(for: blockchain.app.configuration.active.rewards.is.enabled, as: Bool.self)
            .replaceError(with: false)
            .map { [asset, addressFactory] isEnabled -> [SingleAccount] in
                guard isEnabled else {
                    return []
                }
                let account = CryptoActiveRewardsAccount(
                    asset: asset,
                    cryptoReceiveAddressFactory: addressFactory
                ) as SingleAccount
                return [account]
            }
            .eraseToAnyPublisher()
    }

    private var exchangeAccounts: AnyPublisher<[SingleAccount], Never> {
        guard asset.supports(product: .mercuryDeposits) else {
            return .just([])
        }
        return exchangeAccountsProvider
            .account(
                for: asset,
                externalAssetAddressFactory: addressFactory
            )
            .map { [$0 as SingleAccount] }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private var interestAccounts: AnyPublisher<[SingleAccount], Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just([])
        }
        return .just(
            [
                CryptoInterestAccount(
                    asset: asset,
                    cryptoReceiveAddressFactory: addressFactory
                )
            ]
        )
    }

    private var custodialAccounts: AnyPublisher<[SingleAccount], Never> {
        guard asset.supports(product: .custodialWalletBalance) else {
            return .just([])
        }
        return .just(
            [
                CryptoTradingAccount(
                    asset: asset,
                    cryptoReceiveAddressFactory: addressFactory
                )
            ]
        )
    }
}
