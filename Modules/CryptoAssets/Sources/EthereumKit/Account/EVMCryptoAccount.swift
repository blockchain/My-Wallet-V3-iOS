// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

final class EVMCryptoAccount: CryptoNonCustodialAccount, BlockchainAccountActivity {

    private(set) lazy var identifier: String = "EVMCryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let assetName: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    let publicKey: String
    let network: EVMNetwork

    func createTransactionEngine() -> Any {
        EthereumOnChainTransactionEngineFactory(
            network: network
        )
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        shouldUseUnifiedBalance(app: app)
            .eraseError()
            .flatMap { [unifiedBalance, oldBalance] isEnabled in
                isEnabled ? unifiedBalance : oldBalance
            }
            .eraseToAnyPublisher()
    }

    private var oldBalance: AnyPublisher<MoneyValue, Error> {
        ethereumBalanceRepository
            .balance(
                network: network,
                for: publicKey
            )
            .map(\.moneyValue)
            .eraseError()
            .eraseToAnyPublisher()
    }

    private var unifiedBalance: AnyPublisher<MoneyValue, Error> {
        balanceRepository
            .balances
            .map { [asset] balances in
                balances.balance(
                    index: 0,
                    currency: asset
                ) ?? MoneyValue.zero(currency: asset)
            }
            .eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    /// The `ReceiveAddress` for the given account
    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(ethereumReceiveAddress)
    }

    var activity: AnyPublisher<[ActivityItemEvent], Error> {
        nonCustodialActivity
            .zip(swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    var nonce: AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        nonceRepository.nonce(
            network: network,
            for: publicKey
        )
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return isInterestWithdrawAndDepositEnabled
            .zip(canPerformInterestTransfer)
            .map { isEnabled, canPerform in
                isEnabled && canPerform
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: AnyPublisher<[TransactionalActivityItemEvent], Never> {
        switch network.networkConfig {
        case .ethereum:
            // Use old repository
            return activityRepository
                .transactions(address: publicKey)
                .map { response in
                    response.map(\.activityItemEvent)
                }
                .replaceError(with: [])
                .eraseToAnyPublisher()
        default:
            // Use EVM repository
            return evmActivityRepository
                .transactions(network: network, cryptoCurrency: asset, address: publicKey)
                .map { [publicKey] transactions in
                    transactions
                        .map { item in
                            item.activityItemEvent(sourceIdentifier: publicKey)
                        }
                }
                .replaceError(with: [])
                .eraseToAnyPublisher()
        }
    }

    private var ethereumReceiveAddress: EthereumReceiveAddress {
        EthereumReceiveAddress(
            address: publicKey,
            label: label,
            network: network,
            onTxCompleted: onTxCompleted
        )!
    }

    private var ethereumAddress: EthereumAddress {
        EthereumAddress(address: publicKey, network: network)!
    }

    private var swapActivity: AnyPublisher<[SwapActivityItemEvent], Never> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(.interestWithdrawAndDeposit)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private let ethereumBalanceRepository: EthereumBalanceRepositoryAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let activityRepository: HistoricalTransactionsRepositoryAPI
    private let evmActivityRepository: EVMActivityRepositoryAPI
    private let app: AppProtocol
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let repository: EthereumWalletRepositoryAPI

    init(
        network: EVMNetwork,
        publicKey: String,
        label: String? = nil,
        app: AppProtocol = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        activityRepository: HistoricalTransactionsRepositoryAPI = resolve(),
        evmActivityRepository: EVMActivityRepositoryAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        ethereumBalanceRepository: EthereumBalanceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        repository: EthereumWalletRepositoryAPI = resolve()
    ) {
        let asset = network.nativeAsset
        self.asset = asset
        self.assetName = asset.name
        self.network = network
        self.publicKey = publicKey
        self.priceService = priceService
        self.activityRepository = activityRepository
        self.evmActivityRepository = evmActivityRepository
        self.swapTransactionsService = swapTransactionsService
        self.ethereumBalanceRepository = ethereumBalanceRepository
        self.label = label ?? asset.defaultWalletName
        self.featureFlagsService = featureFlagsService
        self.nonceRepository = nonceRepository
        self.app = app
        self.balanceRepository = balanceRepository
        self.repository = repository
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive,
             .send,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            return .just(false)
        case .buy:
            return .just(asset.supports(product: .custodialWalletBalance))
        case .interestTransfer:
            return isInterestTransferAvailable
                .flatMap { [isFunded] isEnabled in
                    isEnabled ? isFunded : .just(false)
                }
                .eraseToAnyPublisher()
        case .stakingDeposit:
            guard asset.supports(product: .staking) else { return .just(false) }
            return isFunded
        case .activeRewardsDeposit:
            guard asset.supports(product: .activeRewardsBalance) else { return .just(false) }
            return isFunded
        case .sell, .swap:
            guard asset.supports(product: .custodialWalletBalance) else {
                return .just(false)
            }
            return hasPositiveDisplayableBalance
        }
    }

    func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never> {
        repository.updateLabel(label: newLabel)
    }

    func invalidateAccountBalance() {
        ethereumBalanceRepository.invalidateCache()
    }
}
