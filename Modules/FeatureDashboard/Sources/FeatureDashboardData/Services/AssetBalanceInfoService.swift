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
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    init(
        nonCustodialBalanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        tradingBalanceService: TradingBalanceServiceAPI,
        coincore: CoincoreAPI,
        app: AppProtocol,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.nonCustodialBalanceRepository = nonCustodialBalanceRepository
        self.coincore = coincore
        self.tradingBalanceService = tradingBalanceService
        self.app = app
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    private func nonCustodialCryptoBalances() -> AnyPublisher<(balances: [CryptoValue], networks: [DelegatedCustodyBalances.Network]), Error> {
        nonCustodialBalanceRepository
            .balances
            .map { balances -> (balances: [CryptoValue], networks: [DelegatedCustodyBalances.Network]) in
                let grouped = balances.balances
                    .reduce(into: [CurrencyType: [DelegatedCustodyBalances.Balance]]()) { partialResult, balance in
                        partialResult[balance.currency, default: []].append(balance)
                    }

                let reduced = grouped
                    .reduce(into: [CurrencyType: MoneyValue]()) { result, element in
                        result[element.key] = try? element.value.map(\.balance)
                            .reduce(MoneyValue.zero(currency: element.key), +)
                    }
                let finalBalances = reduced.values.compactMap(\.cryptoValue)
                let networks = balances.networks
                return (finalBalances, networks)
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
            .replaceError(with: ([], []))
            .flatMap { [app, priceService] cryptoBalances -> AnyPublisher<[AssetBalanceInfo], Never> in
                priceService.prices(
                    cryptoCurrencies: cryptoBalances.balances.map(\.currency).unique,
                    fiatCurrency: fiatCurrency,
                    at: time
                )
                .combineLatest(
                    app.publisher(for: blockchain.ux.dashboard.test.balance.multiplier, as: Int.self)
                        .replaceError(with: 1)
                )
                .map { prices, multiplier -> [AssetBalanceInfo] in
                    AssetBalanceInfo
                        .create(
                            balances: cryptoBalances.balances.map { balance in balance * multiplier },
                            prices: prices,
                            networks: cryptoBalances.networks,
                            enabledCurrenciesService: self.enabledCurrenciesService
                        )
                        .sortedByFiatBalance()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func trading(currency: FiatCurrency, at time: PriceTime) -> AnyPublisher<[AssetBalanceInfo], Never> {

        func info(balance: CustodialAccountBalance, crypto: CryptoCurrency) -> AnyPublisher<AssetBalanceInfo, Never> {

            let today: AnyPublisher<MoneyValue, Never> = priceService.price(of: balance.currency, in: currency, at: time)
                .map(\.moneyValue)
                .catch { _ in
                    // TODO: handle error
                    .zero(currency: currency)
                }
                .eraseToAnyPublisher()

            let yesterday: AnyPublisher<MoneyValue, Never> = priceService.price(of: balance.currency, in: currency, at: .oneDay)
                .map(\.moneyValue)
                .replaceError(with: .zero(currency: currency))
                .eraseToAnyPublisher()

            return today.combineLatest(
                yesterday,
                app.publisher(for: blockchain.ux.dashboard.test.balance.multiplier, as: Int.self)
                    .replaceError(with: 1),
                app.publisher(for: blockchain.app.configuration.prices.rising.fast.percent, as: Double.self)
                    .replaceError(with: 15)
            )
            .map { (quote: MoneyValue, yesterday: MoneyValue, multiplier: Int, fastRisingMinDelta: Double) -> AssetBalanceInfo in
                let delta = try? MoneyValue.delta(yesterday, quote).roundTo(places: 2)
                let isFastRising = Decimal(fastRisingMinDelta / 100).isLessThanOrEqualTo(delta ?? 0)
                var network: EVMNetwork?
                if let cryptoCurrency = balance.currency.cryptoCurrency {
                    network = self.enabledCurrenciesService.network(for: cryptoCurrency)
                }
                return AssetBalanceInfo(
                    cryptoBalance: balance.available * multiplier,
                    fiatBalance: MoneyValuePair(base: balance.available * multiplier, exchangeRate: quote),
                    currency: balance.currency,
                    delta: delta,
                    fastRising: isFastRising,
                    network: network,
                    rawQuote: quote
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

                let today: AnyPublisher<MoneyValue, Never> = priceService.price(of: asset, in: currency, at: time)
                    .map(\.moneyValue)
                    .catch { _ in
                        // TODO: handle error
                        .zero(currency: currency)
                    }
                    .eraseToAnyPublisher()

                let yesterday: AnyPublisher<MoneyValue, Never> = priceService.price(of: asset, in: currency, at: .oneDay)
                    .map(\.moneyValue)
                    .replaceError(with: .zero(currency: currency))
                    .eraseToAnyPublisher()

                return app.publisher(for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance, as: MoneyValue.self)
                    .map(\.value)
                    .replaceNil(with: MoneyValue.zero(currency: asset))
                    .combineLatest(today, yesterday, app.computed(blockchain.ux.dashboard.test.balance.multiplier, as: Int.self).replaceError(with: 1))
                    .map { (crypto: MoneyValue, quote: MoneyValue, yesterday: MoneyValue, multiplier: Int) -> AssetBalanceInfo in
                        AssetBalanceInfo(
                            cryptoBalance: crypto * multiplier,
                            fiatBalance: MoneyValuePair(base: crypto * multiplier, exchangeRate: quote),
                            currency: asset.currencyType,
                            delta: try? MoneyValue.delta(yesterday, quote).roundTo(places: 2),
                            rawQuote: quote
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
                        actions: actions,
                        rawQuote: balance.quote
                    )
                }
                .eraseToAnyPublisher()
        }

        return coincore.accounts(where: { $0 is FiatAccount })
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
    enum AssetBalanceInfoError: Error {
        case noBalance
    }

    mutating func merging(with other: AssetBalanceInfo, fiatCurrency: FiatCurrency) throws {
        self = try merge(with: other, fiatCurrency: fiatCurrency)
    }

    func merge(with other: AssetBalanceInfo, fiatCurrency: FiatCurrency) throws -> AssetBalanceInfo {
        var my = self
        guard let otherBalance = other.balance else {
            return my
        }
        guard let myBalance = my.balance else {
            throw AssetBalanceInfoError.noBalance
        }
        let balance = try myBalance + otherBalance
        my.balance = balance
        let exchangeRate = exchangeRate(other: other, fiatCurrency: fiatCurrency)
        my.fiatBalance = MoneyValuePair(base: balance, exchangeRate: exchangeRate)
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
        if let myQuote = rawQuote, let balance, balance.isPositive, !myQuote.isZero {
            return myQuote
        } else if let otherQuote = other.rawQuote, let otherBalance = other.balance, otherBalance.isPositive, !otherQuote.isZero {
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
        prices: [CryptoCurrency: PriceQuoteAtTime],
        networks: [DelegatedCustodyBalances.Network],
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) -> [AssetBalanceInfo] {
        balances.map { balance -> AssetBalanceInfo in
            var fiatBalance: MoneyValuePair?
            let fiatPrice = prices[balance.currency]
            if let fiatPrice {
                fiatBalance = MoneyValuePair(
                    base: balance.moneyValue,
                    exchangeRate: fiatPrice.moneyValue
                )
            }
            let network = enabledCurrenciesService.network(for: balance.currency)
            let failingNetwork = networks.first(where: { $0.errorLoadingBalances && $0.currency == network?.nativeAsset }).isNotNil
            return AssetBalanceInfo(
                cryptoBalance: balance.moneyValue,
                fiatBalance: fiatBalance,
                currency: balance.currencyType,
                delta: nil,
                network: network,
                balanceFailingForNetwork: failingNetwork,
                rawQuote: fiatPrice?.moneyValue
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

extension Publisher {

    func counting(_ emoji: String, message: String) -> Publishers.HandleEvents<Self> {
        let lock = UnfairLock()
        var count = 0
        return handleEvents(
            receiveSubscription: { _ in
                Swift.print(emoji, count, "\(message) receiveSubscription")
            },
            receiveOutput: { _ in
                lock.lock()
                defer { lock.unlock() }
                count += 1
                Swift.print(emoji, count, "\(message) output")
            },
            receiveCompletion: { completion in
                lock.lock()
                defer { lock.unlock() }
                var updatedMessage: String = message
                if case .failure(let error) = completion {
                    updatedMessage = updatedMessage + "\(error)"
                } else {
                    updatedMessage = updatedMessage + "stream completed"
                }
                Swift.print(emoji, count, updatedMessage)
            },
            receiveCancel: {
                Swift.print(emoji, count, "\(message) receive cancel")
            }
        )
    }
}
