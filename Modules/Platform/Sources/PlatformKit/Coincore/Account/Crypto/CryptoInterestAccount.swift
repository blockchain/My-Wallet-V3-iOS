// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureStakingDomain
import Localization
import MoneyKit
import ToolKit

public final class CryptoInterestAccount: CryptoAccount, InterestAccount {

    private enum CryptoInterestAccountError: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let asset, let label, let action, let error):
                return "Failed to load: 'CryptoInterestAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    public private(set) lazy var identifier: String = "CryptoInterestAccount." + asset.code
    public let label: String
    public var assetName: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public var accountType: AccountType = .trading

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        receiveAddressRepository
            .fetchInterestAccountReceiveAddressForCurrencyCode(asset.code)
            .eraseError()
            .flatMap { [cryptoReceiveAddressFactory, onTxCompleted, asset] addressString in
                cryptoReceiveAddressFactory
                    .makeExternalAssetAddress(
                        address: addressString,
                        label: "\(asset.code) \(LocalizationConstants.rewardsAccount)",
                        onTxCompleted: onTxCompleted
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .map { $0 as ReceiveAddress }
            .eraseToAnyPublisher()
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        balances
            .map { $0 != .absent }
            .eraseError()
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

    public var disabledReason: AnyPublisher<InterestAccountIneligibilityReason, Error> {
        interestEligibilityRepository
            .fetchInterestAccountEligibilityForCurrencyCode(currencyType)
            .map(\.ineligibilityReason)
            .eraseError()
            .eraseToAnyPublisher()
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        // `withdrawable` is the accounts total balance
        // minus the locked funds amount. Only these funds are
        // available for withdraws (which is all you can do with
        // your interest account funds)
        balances
            .map(\.balance)
            .map(\.?.withdrawable)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    private let cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    private let errorRecorder: ErrorRecording
    private let priceService: PriceServiceAPI
    private let interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI
    private let receiveAddressRepository: InterestAccountReceiveAddressRepositoryAPI
    private let balanceService: InterestAccountOverviewAPI

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: asset)
    }

    public init(
        asset: CryptoCurrency,
        receiveAddressRepository: InterestAccountReceiveAddressRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        balanceService: InterestAccountOverviewAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve(),
        cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    ) {
        self.label = asset.defaultInterestWalletName
        self.assetName = asset.name
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.receiveAddressRepository = receiveAddressRepository
        self.asset = asset
        self.errorRecorder = errorRecorder
        self.balanceService = balanceService
        self.priceService = priceService
        self.interestEligibilityRepository = interestEligibilityRepository
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .interestWithdraw:
            return canPerformInterestWithdraw()
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .viewActivity:
            return .just(true)
        case .buy,
             .deposit,
             .interestTransfer,
             .stakingDeposit,
             .stakingWithdraw,
             .receive,
             .sell,
             .send,
             .sign,
             .swap,
             .withdraw,
             .activeRewardsDeposit,
             .activeRewardsWithdraw:
            return .just(false)
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

    private func canPerformInterestWithdraw() -> AnyPublisher<Bool, Never> {
        actionableBalance.map(\.isPositive)
            .mapError { [label, asset] error -> CryptoInterestAccountError in
                .loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .interestWithdraw,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public func invalidateAccountBalance() {
        balanceService
            .invalidateInterestAccountBalances()
    }
}
