// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import Extensions
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
    private let priceService: PriceServiceAPI
    private let app: AppProtocol

    init(
        nonCustodialBalanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        tradingBalanceService: TradingBalanceServiceAPI,
        coincore: CoincoreAPI,
        app: AppProtocol
    ) {
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.nonCustodialBalanceRepository = nonCustodialBalanceRepository
        self.coincore = coincore
        self.tradingBalanceService = tradingBalanceService
        self.app = app
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

    func getCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {
        trading(currency: fiatCurrency, at: time)
            .combineLatest(earn(currency: fiatCurrency, at: time))
            .map { [app] trading, earn -> [AssetBalanceInfo] in
                trading.merge(with: earn, policy: .throw { error in app.post(error: error) })
                    .sorted {
                        guard let first = $0.fiatBalance?.quote, let second = $1.fiatBalance?.quote else { return false }
                        return (try? first > second) ?? false
                    }
            }
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
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

    func trading(currency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {
        tradingBalanceService.balances
            .flatMap { [app, priceService] balances in
                balances.enumeratedBalances.compactMap(\.balance)
                    .compactMap { balance -> AnyPublisher<AssetBalanceInfo, Never>? in
                        guard let crypto = balance.currency.cryptoCurrency else { return nil }
                        return app.publisher(for: blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto.code].fiat.quote.value)
                            .filter { $0.value != nil }
                            .replaceError(with: MoneyValue.zero(currency: currency))
                            .combineLatest(
                                priceService.priceSeries(of: crypto, in: currency, within: .day())
                                    .map(\.deltaPercentage)
                                    .map(Optional.some)
                                    .replaceError(with: nil)
                                    .prepend(nil)
                            )
                            .map { quote, delta in
                                AssetBalanceInfo(
                                    cryptoBalance: balance.available,
                                    fiatBalance: MoneyValuePair(base: balance.available, exchangeRate: quote),
                                    currency: balance.currency,
                                    delta: delta?.roundTo(places: 2)
                                )
                            }
                            .eraseToAnyPublisher()
                    }
                    .combineLatest()
            }
            .eraseToAnyPublisher()
    }

    func earn(currency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {

        func info(
            currency: FiatCurrency,
            product: EarnProduct,
            assets: [CryptoCurrency]
        ) -> AnyPublisher<[AssetBalanceInfo], Never> {
            assets.map { asset -> AnyPublisher<AssetBalanceInfo, Never> in
                app.publisher(for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance, as: MoneyValue.self)
                    .replaceError(with: MoneyValue.zero(currency: asset))
                    .combineLatest(
                        app.publisher(for: blockchain.api.nabu.gateway.price.at.time[time.id].crypto[asset.code].fiat.quote.value)
                            .replaceError(with: MoneyValue.zero(currency: currency)),
                        priceService.priceSeries(of: asset, in: currency, within: .day())
                            .map(\.deltaPercentage)
                            .map(Optional.some)
                            .replaceError(with: nil)
                            .prepend(nil)
                    )
                    .map { (crypto: MoneyValue, quote: MoneyValue, delta: Decimal?) -> AssetBalanceInfo in
                        AssetBalanceInfo(
                            cryptoBalance: crypto,
                            fiatBalance: MoneyValuePair(base: crypto, exchangeRate: quote),
                            currency: asset.currencyType,
                            delta: delta?.roundTo(places: 2)
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .combineLatest()
        }

        return app.publisher(for: blockchain.ux.earn.supported.products, as: [EarnProduct].self).compactMap(\.value)
            .combineLatest(app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self).compactMap(\.value))
            .flatMap { [app] products, currency -> AnyPublisher<[AssetBalanceInfo], Never> in
                products.map { product -> AnyPublisher<[AssetBalanceInfo], Never> in
                    app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                        .replaceError(with: [])
                        .flatMap { assets -> AnyPublisher<[AssetBalanceInfo], Never> in
                            info(currency: currency, product: product, assets: assets)
                        }
                        .eraseToAnyPublisher()
                }
                .combineLatest()
                .map { models in
                    models.flatMap { $0 }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getFiatAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {

        func info(account: FiatAccount, in fiatCurrency: FiatCurrency) -> AnyPublisher<AssetBalanceInfo, Never> {
            account.fiatMainBalanceToDisplay(fiatCurrency: fiatCurrency, at: time)
                .replaceError(with: MoneyValue.zero(currency: account.fiatCurrency.currencyType))
                .combineLatest(account.actions.prepend([]).replaceError(with: []))
                .map { balance, actions in
                    AssetBalanceInfo(
                        cryptoBalance: balance,
                        fiatBalance: nil,
                        currency: account.currencyType,
                        delta: nil,
                        actions: actions
                    )
                }
                .eraseToAnyPublisher()
        }

        return coincore.account(where: { $0 is FiatAccount })
            .replaceError(with: [])
            .map { accounts in accounts.filter(FiatAccount.self) }
            .combineLatest(app.publisher(for: blockchain.user.currency.currencies, as: [FiatCurrency].self))
            .map { accounts, currencies -> [FiatAccount] in
                if let currencies = currencies.value {
                    return accounts.filter { account in currencies.contains(account.fiatCurrency) }
                } else {
                    return accounts
                }
            }
            .map { accounts in
                accounts.sorted(by: { $0.fiatCurrency == fiatCurrency && $1.fiatCurrency != fiatCurrency })
            }
            .flatMap { accounts -> AnyPublisher<[AssetBalanceInfo], Never> in
                accounts.map { account -> AnyPublisher<AssetBalanceInfo, Never> in
                    info(account: account, in: fiatCurrency)
                }
                .combineLatest()
            }
            .eraseToAnyPublisher()
    }
}

extension AssetBalanceInfo {

    mutating func merging(with other: AssetBalanceInfo) throws {
        self = try merge(with: other)
    }

    func merge(with other: AssetBalanceInfo) throws -> AssetBalanceInfo {
        var my = self
        try my.balance += other.balance
        my.fiatBalance = my.fiatBalance.map { balance in
            MoneyValuePair(base: my.balance, exchangeRate: balance.exchangeRate.quote)
        }
        if let actions = other.actions {
            my.actions = my.actions?.union(actions) ?? actions
        }
        return my
    }
}

extension [AssetBalanceInfo] {

    enum ErrorPolicy {
        case `throw`((Error) -> Void)
        case ignore
    }

    func merge(with other: [AssetBalanceInfo], policy: ErrorPolicy = .ignore) -> [AssetBalanceInfo] {
        var my = [String: AssetBalanceInfo](uniqueKeysWithValues: map { ($0.currency.code, $0) })
        for info in other {
            do {
                if let existing = my[info.currency.code] {
                    my[info.currency.code] = try existing.merge(with: info)
                } else {
                    my[info.currency.code] = info
                }
            } catch {
                switch policy {
                case .throw(let throwing):
                    throwing(error)
                case .ignore:
                    break
                }
            }
        }
        return my.values.array
    }
}
