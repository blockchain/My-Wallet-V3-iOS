// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureStakingDomain
import MoneyKit
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: Identifiable, CryptoAccount, TradingAccount {

    private enum CryptoTradingAccountError: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let asset, let label, let action, let error):
                return "Failed to load: 'CryptoTradingAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    public var id: AnyHashable { identifier }
    public private(set) lazy var identifier: String = "CryptoTradingAccount." + asset.code
    public let label: String
    public let assetName: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public var accountType: AccountType = .trading

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        custodialAddressService
            .receiveAddress(for: asset)
            .eraseError()
            .flatMap { [cryptoReceiveAddressFactory, label, onTxCompleted] address in
                cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
                .map { $0 as ReceiveAddress }
                .eraseError()
                .publisher
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        balances
            .map { $0 != .absent }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private var hasPositiveDisplayableBalance: AnyPublisher<Bool, Never> {
        balances
            .map { state in
                state.balance?.available.hasPositiveDisplayableBalance == true
            }
            .eraseToAnyPublisher()
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var mainBalanceToDisplay: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.mainBalanceToDisplay)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance)
            .map { [asset] balance -> (available: MoneyValue, pending: MoneyValue) in
                guard let balance else {
                    return (.zero(currency: asset), .zero(currency: asset))
                }
                return (balance.available, balance.pending)
            }
            .eraseError()
            .tryMap { [asset] values -> MoneyValue in
                guard values.available.isPositive else {
                    return .zero(currency: asset)
                }
                return try values.available - values.pending
            }
            .eraseToAnyPublisher()
    }

    public var withdrawableBalance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.withdrawable)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var onTxCompleted: (TransactionResult) -> AnyPublisher<Void, Error> {
        { [weak self] result -> AnyPublisher<Void, Error> in
            guard let self else {
                return .failure(PlatformKitError.default)
            }
            guard case .hashed(let hash, let amount) = result else {
                return .failure(PlatformKitError.default)
            }
            guard let amount, amount.isCrypto else {
                return .failure(PlatformKitError.default)
            }
            return receiveAddress
                .flatMap { [custodialPendingDepositService] receiveAddress -> AnyPublisher<Void, Error> in
                    custodialPendingDepositService.createPendingDeposit(
                        value: amount,
                        destination: receiveAddress.address,
                        transactionHash: hash,
                        product: "SIMPLEBUY"
                    )
                    .eraseError()
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }

    public var disabledReason: AnyPublisher<InterestAccountIneligibilityReason, Error> {
        interestEligibilityRepository
            .fetchInterestAccountEligibilityForCurrencyCode(currencyType)
            .map(\.ineligibilityReason)
            .eraseError()
    }

    private let balanceService: TradingBalanceServiceAPI
    private let cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    private let custodialAddressService: CustodialAddressServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let errorRecorder: ErrorRecording
    private let stakingService: EarnAccountService
    private let activeRewardsService: EarnAccountService
    private let priceService: PriceServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: asset.currencyType)
    }

    public init(
        asset: CryptoCurrency,
        errorRecorder: ErrorRecording = resolve(),
        priceService: PriceServiceAPI = resolve(),
        stakingService: EarnAccountService = resolve(tag: EarnProduct.staking),
        activeRewardsService: EarnAccountService = resolve(tag: EarnProduct.active),
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
        self.label = asset.defaultTradingWalletName
        self.assetName = asset.name
        self.interestEligibilityRepository = interestEligibilityRepository
        self.priceService = priceService
        self.balanceService = balanceService
        self.stakingService = stakingService
        self.activeRewardsService = activeRewardsService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.kycTiersService = kycTiersService
        self.errorRecorder = errorRecorder
        self.supportedPairsInteractorService = supportedPairsInteractorService
    }

    private var isPairToFiatAvailable: AnyPublisher<Bool, Never> {
        supportedPairsInteractorService
            .pairs
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .replaceError(with: false)
            .prefix(1)
            .eraseToAnyPublisher()
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .viewActivity, .receive:
            return .just(true)
        case .deposit,
             .interestWithdraw,
             .stakingWithdraw,
             .sign,
             .withdraw,
             .activeRewardsWithdraw:
            return .just(false)
        case .send:
            return isFunded
        case .buy:
            return isPairToFiatAvailable
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .sell:
            return canPerformSell
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .swap:
            return canPerformSwap
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .interestTransfer:
            return canPerformInterestTransfer
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .stakingDeposit:
            return canPerformStakingDeposit
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .activeRewardsDeposit:
            return canPerformActiveRewardsDeposit
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func invalidateAccountBalance() {
        balanceService
            .invalidateTradingAccountBalances()
    }

    // MARK: - Private Functions

    private var canPerformSwap: AnyPublisher<Bool, Never> {
        hasPositiveDisplayableBalance
            .flatMap { [eligibilityService] hasPositiveDisplayableBalance -> AnyPublisher<Bool, Never> in
                guard hasPositiveDisplayableBalance else {
                    return .just(false)
                }
                return eligibilityService.isEligiblePublisher
            }
            .eraseToAnyPublisher()
    }

    private var canPerformSell: AnyPublisher<Bool, Never> {
        isPairToFiatAvailable
            .flatMap { [hasPositiveDisplayableBalance] isPairToFiatAvailable -> AnyPublisher<Bool, Never> in
                guard isPairToFiatAvailable else {
                    return .just(false)
                }
                return hasPositiveDisplayableBalance
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private var canPerformInterestTransfer: AnyPublisher<Bool, Never> {
        Publishers
            .Zip(
                disabledReason.map(\.isEligible),
                isFunded
            )
            .map { isEligible, isFunded in
                isEligible && isFunded
            }
            .mapError { [label, asset] error in
                CryptoTradingAccountError.loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .interestTransfer,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var canPerformStakingDeposit: AnyPublisher<Bool, Never> {
        stakingService.eligibility()
            .map(\.[currencyType.code]?.eligible)
            .replaceNil(with: false)
            .eraseError()
            .zip(isFunded)
            .map { $0 && $1 }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var canPerformActiveRewardsDeposit: AnyPublisher<Bool, Never> {
        activeRewardsService.eligibility()
            .map(\.[currencyType.code]?.eligible)
            .replaceNil(with: false)
            .eraseError()
            .zip(isFunded)
            .map { $0 && $1 }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
