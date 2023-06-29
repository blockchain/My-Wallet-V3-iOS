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

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
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
        balance(for: asset)
            .replaceNil(with: MoneyValue.zero(currency: asset))
            .eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(erc20ReceiveAddress)
    }

    /// The nonce (transaction count) of this account.
    var nonce: AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        nonceRepository.nonce(
            network: network,
            for: publicKey
        )
    }

    /// The ethereum balance of this account.
    var nativeBalance: AnyPublisher<CryptoValue, Error> {
        balance(for: network.nativeAsset)
            .map { $0?.cryptoValue }
            .replaceNil(with: CryptoValue.zero(currency: network.nativeAsset))
            .eraseToAnyPublisher()
    }

    private func balance(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<MoneyValue?, Error> {
        balanceRepository
            .balances
            .map { balances in
                balances.balance(
                    index: 0,
                    currency: cryptoCurrency
                )
            }
            .eraseToAnyPublisher()
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return canPerformInterestTransfer
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

    private let erc20Token: AssetModel
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let tradingPairsService: TradingPairsServiceAPI
    private let app: AppProtocol
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI

    init(
        publicKey: String,
        erc20Token: AssetModel,
        network: EVMNetwork,
        app: AppProtocol = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        tradingPairsService: TradingPairsServiceAPI = resolve()
    ) {
        precondition(erc20Token.kind.isERC20)
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        self.asset = erc20Token.cryptoCurrency!
        self.network = network
        self.label = asset.defaultWalletName
        self.assetName = asset.name
        self.nonceRepository = nonceRepository
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.tradingPairsService = tradingPairsService
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
            return .just(true)
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

    func invalidateAccountBalance() {}
}
