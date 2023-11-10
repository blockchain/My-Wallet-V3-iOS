// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Coincore
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import ToolKit

final class StellarCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: String = "StellarCryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let assetName: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        StellarOnChainTransactionEngineFactory(
            walletCurrencyService: DIKit.resolve(),
            currencyConversionService: DIKit.resolve(),
            feeRepository: DIKit.resolve(),
            transactionDispatcher: DIKit.resolve()
        )
    }

    var balance: AnyPublisher<MoneyValue, Error> {
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

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance.map { balance in
            let minimumBalance = stellarMinimumBalance(subentryCount: 0)
            do {
                let result = try balance - minimumBalance.moneyValue
                return result.isPositive ? result : .zero(currency: .stellar)
            } catch {
                return balance
            }
        }
        .eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(StellarReceiveAddress(address: publicKey, label: label))
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return canPerformInterestTransfer
            .eraseToAnyPublisher()
    }

    let publicKey: String
    private let priceService: PriceServiceAPI
    private let app: AppProtocol
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI

    init(
        publicKey: String,
        label: String? = nil,
        app: AppProtocol = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        accountRepository: StellarWalletAccountRepositoryAPI = resolve()
    ) {
        let asset = CryptoCurrency.stellar
        self.asset = asset
        self.publicKey = publicKey
        self.label = label ?? asset.defaultWalletName
        self.assetName = asset.name
        self.priceService = priceService
        self.app = app
        self.balanceRepository = balanceRepository
        self.accountRepository = accountRepository
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive,
             .send,
             .buy,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw,
             .stakingWithdraw,
             .activeRewardsWithdraw:
            return .just(false)
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
        case .sell:
            return hasPositiveDisplayableBalance
        case .swap:
            return .just(true)
        }
    }

    func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never> {
        accountRepository.updateLabel(newLabel)
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
