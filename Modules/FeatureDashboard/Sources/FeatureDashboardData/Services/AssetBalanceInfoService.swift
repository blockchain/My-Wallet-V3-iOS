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

    private func nonCustodialCryptoBalances() -> AnyPublisher<[CryptoValue], Error> {
        nonCustodialBalanceRepository
            .balances
            .map { balances -> [CryptoValue] in
                let grouped: [CurrencyType: [DelegatedCustodyBalances.Balance]] = Dictionary(
                    grouping: balances.balances,
                    by: { $0.balance.currency }
                )
                let reduced = grouped
                    .reduce(into: [CurrencyType: MoneyValue]()) { result, element in
                        result[element.key] = try? element.value.map(\.balance)
                            .reduce(MoneyValue.zero(currency: element.key), +)
                    }
                return reduced
                    .values
                    .compactMap(\.cryptoValue)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    func getCustodialCryptoAssetsInfo(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {
        trading(currency: fiatCurrency, at: time)
            .combineLatest(earn(currency: fiatCurrency, at: time))
            .map { [app] trading, earn -> [AssetBalanceInfo] in
                trading.merge(with: earn, fiatCurrency: fiatCurrency, policy: .throw { error in app.post(error: error) })
                    .sorted {
                        guard let first = $0.fiatBalance?.quote, let second = $1.fiatBalance?.quote else { return false }
                        return (try? first > second) ?? false
                    }
            }
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
            .eraseToAnyPublisher()
    }

    func getNonCustodialCryptoAssetsInfo(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<[AssetBalanceInfo], Never> {
        nonCustodialCryptoBalances()
            .replaceError(with: [])
            .flatMap { [app, priceService] cryptoBalances -> AnyPublisher<[AssetBalanceInfo], Never> in
                priceService.prices(
                    cryptoCurrencies: cryptoBalances.map(\.currency).unique,
                    fiatCurrency: fiatCurrency,
                    at: time
                )
                .combineLatest(
                    app.publisher(for: blockchain.ux.dashboard.test.balance.multiplier, as: Int.self)
                        .replaceError(with: 1)
                )
                .map { prices, multiplier -> [AssetBalanceInfo] in
                    AssetBalanceInfo
                        .create(balances: cryptoBalances.map { balance in balance * multiplier }, prices: prices)
                        .sortedByFiatBalance()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func trading(currency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {

        func info(balance: CustodialAccountBalance, crypto: CryptoCurrency) -> AnyPublisher<AssetBalanceInfo, Never> {

            let today: AnyPublisher<MoneyValue, Never> = app.publisher(
                for: blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto.code].fiat[currency.code].quote.value,
                as: MoneyValue.self
            )
            .compactMap(\.value)
            .eraseToAnyPublisher()

            let yesterday: AnyPublisher<MoneyValue, Never> = app.publisher(
                for: blockchain.api.nabu.gateway.price.at.time[PriceTime.oneDay.id].crypto[crypto.code].fiat[currency.code].quote.value,
                as: MoneyValue.self
            )
            .replaceError(with: MoneyValue.zero(currency: currency))

            return today.combineLatest(
                yesterday,
                app.publisher(for: blockchain.ux.dashboard.test.balance.multiplier, as: Int.self)
                    .replaceError(with: 1),
                app.publisher(for: blockchain.app.configuration.prices.rising.fast.percent, as: Double.self)
                    .compactMap(\.value)
            )
            .map { (quote: MoneyValue, yesterday: MoneyValue, multiplier: Int, fastRisingMinDelta: Double) -> AssetBalanceInfo in
                let delta = try? MoneyValue.delta(yesterday, quote).roundTo(places: 2)
                let isFastRising = Decimal((fastRisingMinDelta)/100).isLessThanOrEqualTo(delta ?? 0)
                
                return AssetBalanceInfo(
                        cryptoBalance: balance.available * multiplier,
                        fiatBalance: MoneyValuePair(base: balance.available * multiplier, exchangeRate: quote),
                        currency: balance.currency,
                        delta: delta,
                        fastRising: isFastRising
                )
            }
            .eraseToAnyPublisher()
        }

        return tradingBalanceService.balances
            .flatMap { balances in
                balances.enumeratedBalances.compactMap(\.balance)
                    .compactMap { balance -> AnyPublisher<AssetBalanceInfo, Never>? in
                        guard let crypto = balance.currency.cryptoCurrency else { return nil }
                        return info(balance: balance, crypto: crypto)
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

                let today: AnyPublisher<MoneyValue, Never> = app.publisher(
                    for: blockchain.api.nabu.gateway.price.at.time[time.id].crypto[asset.code].fiat[currency.code].quote.value,
                    as: MoneyValue.self
                )
                .compactMap(\.value)
                .eraseToAnyPublisher()

                let yesterday: AnyPublisher<MoneyValue, Never> = app.publisher(
                    for: blockchain.api.nabu.gateway.price.at.time[PriceTime.oneDay.id].crypto[asset.code].fiat[currency.code].quote.value,
                    as: MoneyValue.self
                )
                .replaceError(with: MoneyValue.zero(currency: currency))

                return app.publisher(for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance, as: MoneyValue.self)
                    .replaceError(with: MoneyValue.zero(currency: asset))
                    .combineLatest(today, yesterday, app.publisher(for: blockchain.ux.dashboard.test.balance.multiplier, as: Int.self).replaceError(with: 1))
                    .map { (crypto: MoneyValue, quote: MoneyValue, yesterday: MoneyValue, multiplier: Int) -> AssetBalanceInfo in
                        AssetBalanceInfo(
                            cryptoBalance: crypto * multiplier,
                            fiatBalance: MoneyValuePair(base: crypto * multiplier, exchangeRate: quote),
                            currency: asset.currencyType,
                            delta: try? MoneyValue.delta(yesterday, quote).roundTo(places: 2)
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .combineLatest()
        }

        return app
            .publisher(for: blockchain.ux.earn.supported.products, as: [EarnProduct].self).compactMap(\.value)
            .flatMap { [app] products -> AnyPublisher<[AssetBalanceInfo], Never> in
                products.map { product -> AnyPublisher<[AssetBalanceInfo], Never> in
                    app
                        .publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
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
            account.mainBalanceToDisplayPair(fiatCurrency: fiatCurrency, at: time)
                .replaceError(
                    with: MoneyValuePair.zero(baseCurrency: account.fiatCurrency.currencyType, quoteCurrency: fiatCurrency.currencyType)
                )
                .combineLatest(
                    account.actions.prepend([]).replaceError(with: []),
                    app.publisher(for: blockchain.ux.dashboard.test.balance.multiplier, as: Int.self)
                        .replaceError(with: 1)
                )
                .map { balance, actions, multiplier in
                    let balancePairMultiplied = MoneyValuePair(base: balance.base * multiplier, quote: balance.quote * multiplier)
                    return AssetBalanceInfo(
                        cryptoBalance: balancePairMultiplied.base,
                        fiatBalance: balancePairMultiplied,
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

    mutating func merging(with other: AssetBalanceInfo, fiatCurrency: FiatCurrency) throws {
        self = try merge(with: other, fiatCurrency: fiatCurrency)
    }

    func merge(with other: AssetBalanceInfo, fiatCurrency: FiatCurrency) throws -> AssetBalanceInfo {
        var my = self
        try my.balance += other.balance
        let exchangeRate = exchangeRate(other: other, fiatCurrency: fiatCurrency)
        my.fiatBalance = MoneyValuePair(base: my.balance, exchangeRate: exchangeRate)
        if let actions = other.actions {
            my.actions = my.actions?.union(actions) ?? actions
        }
        return my
    }

    /// Provides an exchange rate either from self or from other.
    /// In case there's no balance on `self` (asset) there will be no quote
    /// This checks if `other` (asset) has a balance and a quote and uses that one
    /// otherwise it defaults to zero
    func exchangeRate(other: AssetBalanceInfo, fiatCurrency: FiatCurrency) -> MoneyValue {
        if let myQuote = fiatBalance?.exchangeRate.quote, balance.isPositive, !myQuote.isZero {
            return myQuote
        } else if let otherQuote = other.fiatBalance?.exchangeRate.quote, other.balance.isPositive, !otherQuote.isZero {
            return otherQuote
        } else {
            return .zero(currency: fiatCurrency)
        }
    }
}

extension [AssetBalanceInfo] {

    enum ErrorPolicy {
        case `throw`((Error) -> Void)
        case ignore
    }

    func merge(with other: [AssetBalanceInfo], fiatCurrency: FiatCurrency, policy: ErrorPolicy = .ignore) -> [AssetBalanceInfo] {
        var my = [String: AssetBalanceInfo](uniqueKeysWithValues: map { ($0.currency.code, $0) })
        for info in other {
            do {
                if let existing = my[info.currency.code] {
                    my[info.currency.code] = try existing.merge(with: info, fiatCurrency: fiatCurrency)
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

extension PriceServiceAPI {

    /// Fetches prices in the given fiat currency for all crypto currencies
    /// - returns: A map of `CryptoCurrency` and `PriceQuoteAtTime` for all price requests that succeeded.
    fileprivate func prices(
        cryptoCurrencies: [CryptoCurrency],
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<[CryptoCurrency: PriceQuoteAtTime], Never> {
        let pricePublishers: [AnyPublisher<(CryptoCurrency, PriceQuoteAtTime)?, Never>] = cryptoCurrencies
            .map { cryptoCurrency -> AnyPublisher<(CryptoCurrency, PriceQuoteAtTime)?, Never> in
                self.price(of: cryptoCurrency, in: fiatCurrency, at: time)
                    .map { (cryptoCurrency, $0) }
                    .optional()
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
        return pricePublishers
            .zip()
            .map { prices -> [CryptoCurrency: PriceQuoteAtTime] in
                prices
                    .reduce(into: [CryptoCurrency: PriceQuoteAtTime]()) { result, element in
                        if let element {
                            result[element.0] = element.1
                        }
                    }
            }
            .eraseToAnyPublisher()
    }
}

extension AssetBalanceInfo {

    /// Creates an array of `AssetBalanceInfo` .
    static func create(
        balances: [CryptoValue],
        prices: [CryptoCurrency: PriceQuoteAtTime]
    ) -> [AssetBalanceInfo] {
        balances.compactMap { balance -> AssetBalanceInfo? in
            guard let fiatPrice = prices[balance.currency] else {
                return nil
            }
            return AssetBalanceInfo(
                cryptoBalance: balance.moneyValue,
                fiatBalance: MoneyValuePair(
                    base: balance.moneyValue,
                    exchangeRate: fiatPrice.moneyValue
                ),
                currency: balance.currencyType,
                delta: nil
            )
        }
    }
}

extension [AssetBalanceInfo] {

    /// Sort an array of `AssetBalanceInfo` descending by their `fiatBalance`.
    func sortedByFiatBalance() -> [AssetBalanceInfo] {
        sorted(by: { lhs, rhs in
            guard
                let first = lhs.fiatBalance?.quote,
                let second = rhs.fiatBalance?.quote
            else {
                return false
            }
            return (try? first > second) ?? false
        })
    }
}
