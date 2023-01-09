// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import FeatureDashboardDomain
import FeatureStakingDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

protocol AssetBalanceInfoServiceAPI {
    func getCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never>
    func getFiatAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never>
    func getNonCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never>
}

final class AssetBalanceInfoService: AssetBalanceInfoServiceAPI {
    private let nonCustodialBalanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let coincore: CoincoreAPI
    private let tradingBalanceService: TradingBalanceServiceAPI
    private let stakingAccountService: EarnAccountService
    private let savingsAccountService: EarnAccountService
    private let priceService: PriceServiceAPI
    private let app: AppProtocol

    init(
        nonCustodialBalanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        tradingBalanceService: TradingBalanceServiceAPI,
        stakingAccountService: EarnAccountService,
        savingsAccountService: EarnAccountService,
        coincore: CoincoreAPI,
        app: AppProtocol
    ) {
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.nonCustodialBalanceRepository = nonCustodialBalanceRepository
        self.coincore = coincore
        self.tradingBalanceService = tradingBalanceService
        self.stakingAccountService = stakingAccountService
        self.savingsAccountService = savingsAccountService
        self.app = app
    }

    // @paulo @audrea: Stop using Coincore.
    private func getFiatAssetsInfoAsync(fiatCurrency: FiatCurrency, at time: PriceTime) async -> [AssetBalanceInfo] {
        var assetsInfo: [AssetBalanceInfo] = []

        let userFiatCurrencies = try? await app.publisher(for: blockchain.user.currency.currencies, as: [FiatCurrency].self)
            .compactMap(\.value)
            .await()
        let asset = coincore.fiatAsset
        if let accountGroup = try? await asset.accountGroup(filter: .all).await() {
            let sortedAccounts: [SingleAccount]
            if let fiatCurrencies = userFiatCurrencies {
                sortedAccounts = fiatCurrencies.compactMap { currency in
                    accountGroup.accounts.first(
                        where: { $0.currencyType.fiatCurrency == currency }
                    )
                }
                .sorted(by: { $0.currencyType.fiatCurrency == fiatCurrency && $1.currencyType.fiatCurrency != fiatCurrency })
            } else {
                sortedAccounts = accountGroup
                    .accounts
                    .sorted(by: { $0.currencyType.fiatCurrency == fiatCurrency && $1.currencyType.fiatCurrency != fiatCurrency })
            }

            for account in sortedAccounts {
                if let balance = try? await account.fiatMainBalanceToDisplay(fiatCurrency: fiatCurrency, at: time).await() {
                    let actions = try? await account.actions.await()
                    assetsInfo.append(
                        AssetBalanceInfo(
                            cryptoBalance: balance,
                            fiatBalance: nil,
                            currency: account.currencyType,
                            delta: nil,
                            actions: actions
                        )
                    )
                }
            }
        }

        return assetsInfo
    }

    private func getNonCustodialCryptoAssetsInfoAsync(fiatCurrency: FiatCurrency, at time: PriceTime) async -> [AssetBalanceInfo] {
        var assetsInfo: [AssetBalanceInfo] = []
        if let balanceInfo = try? await nonCustodialBalanceRepository.balances.await() {
            let groupedDictionary = Dictionary(grouping: balanceInfo.balances, by: { $0.balance.currency.name })
            var groupedTotalBalances: [MoneyValue] = []
            groupedDictionary.forEach { _, balances in
                if let firstBalance = balances.first?.balance,
                   let cryptoCurrency = firstBalance.currencyType.cryptoCurrency
                {
                    let balanceSum = balances.reduce(into: MoneyValue.zero(currency: cryptoCurrency)) { partialResult, element in
                        try? partialResult += element.balance
                    }
                    groupedTotalBalances.append(balanceSum)
                }
            }

            for balance in groupedTotalBalances {
                let currencyType = balance.currencyType
                if let cryptoCurrency = currencyType.cryptoCurrency,
                   let fiatBalance = try? await priceService
                    .price(of: cryptoCurrency, in: fiatCurrency, at: time)
                    .await()
                {
                    assetsInfo.append(AssetBalanceInfo(
                        cryptoBalance: balance,
                        fiatBalance: MoneyValuePair(base: balance, exchangeRate: fiatBalance.moneyValue),
                        currency: currencyType,
                        delta: nil
                    ))
                }
            }
        }

        // TODO: - Move sorting to a separate service. This will give us more flexibility
        return assetsInfo.sorted(by: {
            guard let first = $0.fiatBalance?.quote, let second = $1.fiatBalance?.quote else {
                return false
            }
            return (try? first > second) ?? false
        })
    }

    private func getCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) async -> [AssetBalanceInfo] {
        guard let allTradingBalances = try? await tradingBalanceService.balances.await() else {
            return []
        }

        var assetsInfo: [AssetBalanceInfo] = []

        for tradingBalance in allTradingBalances.enumeratedBalances {

            if let tradingAvailableBalance = tradingBalance.balance?.available,
               let currency = tradingBalance.balance?.currency,
               let cryptoCurrency = currency.cryptoCurrency
            {
                let savingsBalance = try? await savingsAccountService.balance(for: cryptoCurrency).await()
                let stakingBalance = try? await stakingAccountService.balance(for: cryptoCurrency).await()

                async let fiatBalance = try? await priceService
                    .price(of: cryptoCurrency, in: fiatCurrency, at: time)
                    .await()

                async let prices = try? await priceService.priceSeries(
                    of: cryptoCurrency,
                    in: fiatCurrency,
                    within: .day()
                )
                    .await()

                // Start with Trading Balance
                var totalCryptoBalance = tradingAvailableBalance

                // Add Savings Balance
                if let savingsBalance = savingsBalance?.balance?.moneyValue {
                    try? totalCryptoBalance += savingsBalance
                }

                // Add Staking Balance
                if let stakingBalance = stakingBalance?.balance?.moneyValue {
                    try? totalCryptoBalance += stakingBalance
                }

                if let fiatBalance = await fiatBalance {
                    let fiatBalance = MoneyValuePair(base: totalCryptoBalance, exchangeRate: fiatBalance.moneyValue)
                    assetsInfo.append(await AssetBalanceInfo(
                        cryptoBalance: totalCryptoBalance,
                        fiatBalance: fiatBalance,
                        currency: currency,
                        delta: prices?.deltaPercentage.roundTo(places: 2)
                    ))
                }
            }
        }

        // TODO: - Move sorting to a separate service. This will give us more flexibility
        return assetsInfo.sorted(by: {
            guard let first = $0.fiatBalance?.quote, let second = $1.fiatBalance?.quote else {
                return false
            }
            return (try? first > second) ?? false
        })
    }

    func getCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {
        Deferred { [self] in
            Future { promise in
                Task {
                    do {
                        promise(.success(await self.getCustodialCryptoAssetsInfo(fiatCurrency: fiatCurrency, at: time)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getNonCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {
        Deferred { [self] in
            Future { promise in
                Task {
                    do {
                        promise(.success(await self.getNonCustodialCryptoAssetsInfoAsync(fiatCurrency: fiatCurrency, at: time)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getFiatAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {
        Deferred { [self] in
            Future { promise in
                Task {
                    do {
                        promise(.success(await self.getFiatAssetsInfoAsync(fiatCurrency: fiatCurrency, at: time)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
