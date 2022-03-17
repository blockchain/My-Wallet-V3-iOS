// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: CryptoAccount, TradingAccount {

    private enum Error: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let asset, let label, let action, let error):
                return "Failed to load: 'CryptoTradingAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoTradingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        custodialAddressService
            .receiveAddress(for: asset)
            .flatMap(weak: self) { (self, address) in
                self.cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    address: address,
                    label: self.label,
                    onTxCompleted: self.onTxCompleted
                )
                .single
                .map { $0 as ReceiveAddress }
            }
    }

    public var isFunded: Single<Bool> {
        balances
            .map { $0 != .absent }
            .asSingle()
    }

    public var pendingBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .asSingle()
    }

    public var balance: Single<MoneyValue> {
        balancePublisher.asSingle()
    }

    public var balancePublisher: AnyPublisher<MoneyValue, Swift.Error> {
        balances
            .map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .mapError()
    }

    public var actionableBalance: Single<MoneyValue> {
        balances
            .map(\.balance)
            .map { [asset] balance -> (available: MoneyValue, pending: MoneyValue) in
                guard let balance = balance else {
                    return (.zero(currency: asset), .zero(currency: asset))
                }
                return (balance.available, balance.pending)
            }
            .asSingle()
            .map { [asset] values -> MoneyValue in
                guard values.available.isPositive else {
                    return .zero(currency: asset)
                }
                return try values.available - values.pending
            }
    }

    public var withdrawableBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.withdrawable)
            .replaceNil(with: .zero(currency: currencyType))
            .asSingle()
    }

    public var onTxCompleted: (TransactionResult) -> Completable {
        { [weak self] result -> Completable in
            guard let self = self else {
                return .error(PlatformKitError.default)
            }
            guard case .hashed(let hash, let amount) = result else {
                return .error(PlatformKitError.default)
            }
            guard let amount = amount, amount.isCrypto else {
                return .error(PlatformKitError.default)
            }
            return self.receiveAddress
                .flatMapCompletable(weak: self) { (self, receiveAddress) -> Completable in
                    self.custodialPendingDepositService.createPendingDeposit(
                        value: amount,
                        destination: receiveAddress.address,
                        transactionHash: hash,
                        product: "SIMPLEBUY"
                    )
                }
        }
    }

    public var disabledReason: AnyPublisher<InterestAccountIneligibilityReason, Swift.Error> {
        interestEligibilityRepository
            .fetchInterestAccountEligibilityForCurrencyCode(currencyType.code)
            .map(\.ineligibilityReason)
            .eraseError()
    }

    public var actions: Single<AvailableActions> {
        Single.zip(
            balance,
            eligibilityService.isEligible,
            isPairToFiatAvailable,
            canPerformInterestTransfer()
        )
        .map { balance, isEligible, isPairToFiatAvailable, interestTransferAvailable -> AvailableActions in
            var base: AvailableActions = [.viewActivity, .receive]
            if isPairToFiatAvailable {
                base.insert(.buy)
            }
            if balance.isPositive {
                base.insert(.send)
            }
            if interestTransferAvailable {
                base.insert(.interestTransfer)
            }
            if balance.isPositive, isEligible {
                base.insert(.sell)
                base.insert(.swap)
            }
            return base
        }
    }

    public var activity: Single<[ActivityItemEvent]> {
        Single
            .zip(
                buySellActivity.buySellActivityEvents(cryptoCurrency: asset),
                ordersActivity.activity(cryptoCurrency: asset).catchAndReturn([]),
                swapActivity.fetchActivity(cryptoCurrency: asset, directions: [.internal])
                    .catchAndReturn([])
            )
            .map { buySellActivity, ordersActivity, swapActivity -> [ActivityItemEvent] in
                let swapAndSellActivityItemsEvents: [ActivityItemEvent] = swapActivity
                    .map { item in
                        if item.pair.outputCurrencyType.isFiatCurrency {
                            return .buySell(.init(swapActivityItemEvent: item))
                        }
                        return .swap(item)
                    }

                return buySellActivity.map(ActivityItemEvent.buySell)
                    + ordersActivity.map(ActivityItemEvent.crypto)
                    + swapAndSellActivityItemsEvents
            }
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(
                .remote(.interestWithdrawAndDeposit)
            )
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let balanceService: TradingBalanceServiceAPI
    private let cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    private let custodialAddressService: CustodialAddressServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let errorRecorder: ErrorRecording
    private let priceService: PriceServiceAPI
    private let featureFlagService: FeatureFlagsServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: asset.currencyType)
    }

    public init(
        asset: CryptoCurrency,
        swapActivity: SwapActivityServiceAPI = resolve(),
        ordersActivity: OrdersActivityServiceAPI = resolve(),
        buySellActivity: BuySellActivityItemEventServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        featureFlagService: FeatureFlagsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        balanceService: TradingBalanceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: ExternalAssetAddressFactory,
        custodialAddressService: CustodialAddressServiceAPI = resolve(),
        custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve()
    ) {
        self.asset = asset
        label = asset.defaultTradingWalletName
        self.interestEligibilityRepository = interestEligibilityRepository
        self.ordersActivity = ordersActivity
        self.swapActivity = swapActivity
        self.buySellActivity = buySellActivity
        self.priceService = priceService
        self.balanceService = balanceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.featureFlagService = featureFlagService
        self.kycTiersService = kycTiersService
        self.errorRecorder = errorRecorder
        self.supportedPairsInteractorService = supportedPairsInteractorService
        featureFlagsService = featureFlagService
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

    public func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .send:
            return canPerformSend()
        case .buy:
            return isPairToFiatAvailable
        case .sell:
            return Single.zip(isPairToFiatAvailable, isFunded).map {
                $0.0 && $0.1
            }
        case .swap:
            return canPerformSwap()
        case .receive:
            return .just(true)
        case .interestTransfer:
            return canPerformInterestTransfer()
        case .deposit,
             .interestWithdraw,
             .sign,
             .withdraw:
            return .just(false)
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Swift.Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balancePublisher)
            .tryMap { fiatPrice, balance in
                MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Functions

    private func canPerformSwap() -> Single<Bool> {
        balance
            .map(\.isPositive)
            .flatMap(weak: self) { (self, isPositive) -> Single<Bool> in
                guard isPositive else {
                    return .just(false)
                }
                return self.eligibilityService.isEligible
            }
            .catch { [label, asset] error in
                throw Error.loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .swap,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .catchAndReturn(false)
    }

    private func canPerformInterestTransfer() -> Single<Bool> {
        let isEligible = disabledReason
            .map(\.isEligible)
            .asSingle()
        let balanceAvailable = balance
            .map(\.isPositive)
        let isFeatureFlagEnabled = isInterestWithdrawAndDepositEnabled
            .asSingle()
        return Single
            .zip(isEligible, balanceAvailable, isFeatureFlagEnabled)
            .map { $0 && $1 && $2 }
            .catch { [label, asset] error in
                throw Error.loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .interestTransfer,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .catchAndReturn(false)
    }

    private func canPerformSend() -> Single<Bool> {
        balance
            .map(\.isPositive)
            .catch { [label, asset] error in
                throw Error.loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .send,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .catchAndReturn(false)
    }

    public func invalidateAccountBalance() {
        balanceService
            .invalidateTradingAccountBalances()
    }
}
