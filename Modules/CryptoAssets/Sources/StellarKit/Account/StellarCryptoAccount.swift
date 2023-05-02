// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

final class StellarCryptoAccount: CryptoNonCustodialAccount, BlockchainAccountActivity {

    private(set) lazy var identifier: String = "StellarCryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let assetName: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        StellarOnChainTransactionEngineFactory()
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
        accountDetails
            .map(\.balance.moneyValue)
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

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        shouldUseUnifiedBalance(app: app)
            .eraseError()
            .flatMap { [unifiedBalance, oldActionableBalance] isEnabled in
                isEnabled ? unifiedBalance : oldActionableBalance
            }
            .eraseToAnyPublisher()
    }

    var oldActionableBalance: AnyPublisher<MoneyValue, Error> {
        accountDetails
            .map(\.actionableBalance.moneyValue)
            .eraseError()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(StellarReceiveAddress(address: publicKey, label: label))
    }

    var activity: AnyPublisher<[ActivityItemEvent], Error> {
        nonCustodialActivity.zip(swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    private var accountDetails: AnyPublisher<StellarAccountDetails, StellarNetworkError> {
        accountDetailsService.details(accountID: publicKey)
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

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(.interestWithdrawAndDeposit)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: AnyPublisher<[TransactionalActivityItemEvent], Never> {
        operationsService
            .transactions(accountID: publicKey, size: 50)
            .asPublisher()
            .map { response in
                response
                    .map(\.activityItemEvent)
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private var swapActivity: AnyPublisher<[SwapActivityItemEvent], Never> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    let publicKey: String
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let accountDetailsService: StellarAccountDetailsRepositoryAPI
    private let priceService: PriceServiceAPI
    private let operationsService: StellarHistoricalTransactionServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let app: AppProtocol
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI

    init(
        publicKey: String,
        label: String? = nil,
        app: AppProtocol = resolve(),
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI = resolve(),
        operationsService: StellarHistoricalTransactionServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        accountDetailsService: StellarAccountDetailsRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        accountRepository: StellarWalletAccountRepositoryAPI = resolve()
    ) {
        let asset = CryptoCurrency.stellar
        self.asset = asset
        self.publicKey = publicKey
        self.label = label ?? asset.defaultWalletName
        self.assetName = asset.name
        self.accountDetailsService = accountDetailsService
        self.swapTransactionsService = swapTransactionsService
        self.operationsService = operationsService
        self.priceService = priceService
        self.featureFlagsService = featureFlagsService
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
        case .sell, .swap:
            return hasPositiveDisplayableBalance
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

    func invalidateAccountBalance() {
        accountDetailsService.invalidateCache()
    }
}
