// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount, BlockchainAccountActivity {
    private(set) lazy var identifier: String = "ERC20CryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let assetName: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    let network: EVMNetwork
    let publicKey: String

    func createTransactionEngine() -> Any {
        ERC20OnChainTransactionEngineFactory(erc20Token: erc20Token)
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
        balanceService
            .balance(for: ethereumAddress, cryptoCurrency: asset, network: network.networkConfig)
            .map(\.moneyValue)
            .eraseError()
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

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(erc20ReceiveAddress)
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

    /// The nonce (transaction count) of this account.
    var nonce: AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        nonceRepository.nonce(
            network: network,
            for: publicKey
        )
    }

    /// The ethereum balance of this account.
    var ethereumBalance: AnyPublisher<CryptoValue, EthereumBalanceRepositoryError> {
        ethereumBalanceRepository.balance(
            network: network,
            for: publicKey
        )
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return canPerformInterestTransfer
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: AnyPublisher<[TransactionalActivityItemEvent], Never> {
        switch network {
        case .ethereum:
            // Use old repository
            return erc20ActivityRepository
                .transactions(erc20Asset: erc20Token, address: ethereumAddress)
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

    private var swapActivity: AnyPublisher<[SwapActivityItemEvent], Never> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    /// Stream a boolean indicating if this ERC20 token has ever been transacted,
    private var hasHistory: AnyPublisher<Bool, Never> {
        erc20TokenAccountsRepository
            .tokens(for: ethereumAddress, network: network.networkConfig)
            .map { [asset] tokens in
                tokens[asset] != nil
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var ethereumAddress: EthereumAddress {
        EthereumAddress(address: publicKey, network: network)!
    }

    private var erc20ReceiveAddress: ERC20ReceiveAddress {
        ERC20ReceiveAddress(
            asset: asset,
            address: publicKey,
            label: label,
            onTxCompleted: onTxCompleted,
            enabledCurrenciesService: DIKit.resolve()
        )!
    }

    private let balanceService: ERC20BalanceServiceAPI
    private let erc20Token: AssetModel
    private let erc20TokenAccountsRepository: ERC20BalancesRepositoryAPI
    private let ethereumBalanceRepository: EthereumBalanceRepositoryAPI
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let erc20ActivityRepository: ERC20ActivityRepositoryAPI
    private let evmActivityRepository: EVMActivityRepositoryAPI
    private let tradingPairsService: TradingPairsServiceAPI
    private let app: AppProtocol
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI

    init(
        publicKey: String,
        erc20Token: AssetModel,
        network: EVMNetwork,
        app: AppProtocol = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        balanceService: ERC20BalanceServiceAPI = resolve(),
        erc20TokenAccountsRepository: ERC20BalancesRepositoryAPI = resolve(),
        ethereumBalanceRepository: EthereumBalanceRepositoryAPI = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        tradingPairsService: TradingPairsServiceAPI = resolve(),
        erc20ActivityRepository: ERC20ActivityRepositoryAPI = resolve(),
        evmActivityRepository: EVMActivityRepositoryAPI = resolve()
    ) {
        precondition(erc20Token.kind.isERC20)
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        self.asset = erc20Token.cryptoCurrency!
        self.network = network
        self.label = asset.defaultWalletName
        self.assetName = asset.name
        self.balanceService = balanceService
        self.erc20TokenAccountsRepository = erc20TokenAccountsRepository
        self.ethereumBalanceRepository = ethereumBalanceRepository
        self.nonceRepository = nonceRepository
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.swapTransactionsService = swapTransactionsService
        self.tradingPairsService = tradingPairsService
        self.erc20ActivityRepository = erc20ActivityRepository
        self.evmActivityRepository = evmActivityRepository
        self.app = app
        self.balanceRepository = balanceRepository
    }

    private var isPairToFiatAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .custodialWalletBalance) else {
            return .just(false)
        }
        return supportedPairsInteractorService
            .pairs
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .replaceError(with: false)
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private var isPairToCryptoAvailable: AnyPublisher<Bool, Never> {
        tradingPairsService
            .tradingPairs
            .map { [asset] tradingPairs in
                tradingPairs.contains { pair in
                    pair.sourceCurrencyType == asset
                }
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive:
            return .just(true)
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
        case .deposit,
             .sign,
             .withdraw,
             .stakingWithdraw,
             .interestWithdraw,
             .activeRewardsWithdraw:
            return .just(false)
        case .viewActivity:
            return hasHistory
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .send:
            return isFunded
        case .swap:
            return isPairToCryptoAvailable
                .flatMap { [hasPositiveDisplayableBalance] isPairToCryptoAvailable -> AnyPublisher<Bool, Never> in
                    guard isPairToCryptoAvailable else {
                        return .just(false)
                    }
                    return hasPositiveDisplayableBalance
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .buy:
            return isPairToFiatAvailable
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .sell:
            return isPairToFiatAvailable
                .flatMap { [hasPositiveDisplayableBalance] isPairToFiatAvailable -> AnyPublisher<Bool, Never> in
                    guard isPairToFiatAvailable else {
                        return .just(false)
                    }
                    return hasPositiveDisplayableBalance
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
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

    func invalidateAccountBalance() {
        erc20TokenAccountsRepository.invalidateCache(for: ethereumAddress, network: network.networkConfig)
    }
}
