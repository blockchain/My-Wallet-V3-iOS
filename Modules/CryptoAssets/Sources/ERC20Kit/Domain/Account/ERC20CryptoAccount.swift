// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
    private(set) lazy var identifier: AnyHashable = "ERC20CryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    let network: EVMNetwork
    let publicKey: String

    func createTransactionEngine() -> Any {
        ERC20OnChainTransactionEngineFactory(erc20Token: erc20Token)
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: EthereumAddress(address: publicKey)!, cryptoCurrency: asset)
            .asSingle()
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var actions: Single<AvailableActions> {
        Single.zip(
            isFunded,
            isPairToFiatAvailable,
            hasHistory.asSingle(),
            isInterestTransferAvailable.asSingle()
        )
        .map { isFunded, isPairToFiatAvailable, hasHistory, isInterestEnabled -> AvailableActions in
            var base: AvailableActions = [.receive]
            if hasHistory || isFunded {
                base.insert(.viewActivity)
            }
            if isPairToFiatAvailable {
                base.insert(.buy)
            }
            if isFunded {
                base.formUnion([.send, .swap])
            }
            if isFunded {
                base.insert(.sell)
            }
            if isFunded, isInterestEnabled {
                base.insert(.interestTransfer)
            }
            return base
        }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(
            ERC20ReceiveAddress(
                asset: asset,
                address: publicKey,
                label: label,
                onTxCompleted: onTxCompleted
            )!
        )
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
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
        Single.zip(
            canPerformInterestTransfer(),
            isInterestWithdrawAndDepositEnabled
                .asSingle()
        )
        .map { $0.0 && $0.1 }
        .asPublisher()
        .replaceError(with: false)
        .eraseToAnyPublisher()
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(
                .remote(.interestWithdrawAndDeposit)
            )
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(erc20Asset: erc20Token, address: EthereumAddress(address: publicKey)!)
            .map { response in
                response
                    .map(\.activityItemEvent)
            }
            .catchAndReturn([])
    }

    private var swapActivity: Single<[SwapActivityItemEvent]> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .catchAndReturn([])
    }

    /// Stream a boolean indicating if this ERC20 token has ever been transacted,
    private var hasHistory: AnyPublisher<Bool, Never> {
        erc20TokenAccountsRepository
            .tokens(for: EthereumAddress(address: publicKey)!)
            .map { [asset] tokens in
                tokens[asset] != nil
            }
            .replaceError(with: false)
            .ignoreFailure()
    }

    private let balanceService: ERC20BalanceServiceAPI
    private let erc20Token: AssetModel
    private let erc20TokenAccountsRepository: ERC20TokenAccountsRepositoryAPI
    private let ethereumBalanceRepository: EthereumBalanceRepositoryAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let transactionsService: ERC20HistoricalTransactionServiceAPI

    init(
        publicKey: String,
        erc20Token: AssetModel,
        balanceService: ERC20BalanceServiceAPI = resolve(),
        erc20TokenAccountsRepository: ERC20TokenAccountsRepositoryAPI = resolve(),
        ethereumBalanceRepository: EthereumBalanceRepositoryAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        transactionsService: ERC20HistoricalTransactionServiceAPI = resolve()
    ) {
        precondition(erc20Token.kind.isERC20)
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        asset = erc20Token.cryptoCurrency!
        network = erc20Token.evmNetwork!
        label = asset.defaultWalletName
        self.balanceService = balanceService
        self.erc20TokenAccountsRepository = erc20TokenAccountsRepository
        self.ethereumBalanceRepository = ethereumBalanceRepository
        self.featureFlagsService = featureFlagsService
        self.nonceRepository = nonceRepository
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.swapTransactionsService = swapTransactionsService
        self.transactionsService = transactionsService
    }

    private var isPairToFiatAvailable: Single<Bool> {
        supportedPairsInteractorService
            .pairs
            .take(1)
            .asSingle()
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .catchAndReturn(false)
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive:
            return .just(true)
        case .interestTransfer:
            return isInterestTransferAvailable
                .asSingle()
                .flatMap { [isFunded] isEnabled in
                    isEnabled ? isFunded : .just(false)
                }
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw:
            return .just(false)
        case .viewActivity:
            return hasHistory.asSingle()
        case .send,
             .swap:
            return isFunded
        case .buy:
            return isPairToFiatAvailable
        case .sell:
            return Single.zip(isPairToFiatAvailable, isFunded).map {
                $0.0 && $0.1
            }
        }
    }

    func balancePair(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValuePair, Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balancePublisher)
            .tryMap { fiatPrice, balance in
                MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }

    func invalidateAccountBalance() {
        erc20TokenAccountsRepository.invalidateERC20TokenAccountsForAddress(
            EthereumAddress(address: publicKey)!
        )
    }
}
