// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Extensions
import Foundation
import MoneyKit
import ToolKit

public final class DashboardAssetsObserver: Client.Observer {
    private unowned let app: AppProtocol
    private let service: AssetBalanceInfoServiceAPI
    private let priceService: PriceServiceAPI
    private var lifetimeBag: Set<AnyCancellable> = []
    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        repository: AssetBalanceInfoServiceAPI = DIKit.resolve(),
        priceService: PriceServiceAPI = DIKit.resolve()
    ) {
        self.app = app
        self.service = repository
        self.priceService = priceService
    }

    public func start() {
        app.on(blockchain.session.event.did.sign.in)
            .sink(receiveValue: { [weak self] _ in
                self?.observe()
            })
            .store(in: &lifetimeBag)

        app.on(blockchain.session.event.did.sign.out)
            .sink(receiveValue: { [weak self] _ in
                self?.cancellables = []
            })
            .store(in: &lifetimeBag)
    }

    private func observe() {
        let refreshEvents = app.on(blockchain.ux.home.event.did.pull.to.refresh).mapToVoid()
            .merge(with: app.on(blockchain.ux.transaction.event.did.finish).mapToVoid())
            .mapToVoid()

        let currencyEvent = app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .combineLatest(refreshEvents.prepend(()))
            .share()

        currencyEvent
            .flatMapLatest { [service] fiatCurrency, _ -> AnyPublisher<AssetBalanceInfoResult, Never> in
                service.getCustodialCryptoAssetsInfo(fiatCurrency: fiatCurrency, at: .now)
                    .result()
                    .map { [weak self] result in
                        if let error = result.failure {
                            self?.app.post(error: error)
                        }
                        return AssetBalanceInfoResult(info: result.success ?? [], fiatCurrency: fiatCurrency, hasError: result.isFailure)
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [app] result in
                app.state.set(blockchain.ux.dashboard.trading.assets.crypto, to: result)
            }
            .store(in: &cancellables)

        currencyEvent
            .flatMapLatest { [service] fiatCurrency, _ -> AnyPublisher<AssetBalanceInfoResult, Never> in
                service.getNonCustodialCryptoAssetsInfo(fiatCurrency: fiatCurrency, at: .now)
                    .result()
                    .map { [weak self] result in
                        if let error = result.failure {
                            self?.app.post(error: error)
                        }
                        return AssetBalanceInfoResult(info: result.success ?? [], fiatCurrency: fiatCurrency, hasError: result.isFailure)
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [app] result in
                app.state.set(blockchain.ux.dashboard.defi.assets.info, to: result)
            }
            .store(in: &cancellables)

        currencyEvent
            .combineLatest(
                app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
                    .compactMap(\.value)
            )
            .flatMapLatest { [service] fiatCurrency, tradingCurrency -> AnyPublisher<FiatBalanceInfoResult, Never> in
                service.getFiatAssetsInfo(fiatCurrency: fiatCurrency.0, at: .now)
                    .result()
                    .map { [weak self] result in
                        if let error = result.failure {
                            self?.app.post(error: error)
                        }
                        let fiatBalances = FiatBalancesInfo(balances: result.success ?? [], tradingCurrency: tradingCurrency)
                        return FiatBalanceInfoResult(info: fiatBalances, hasError: result.isFailure)
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [app] result in
                app.state.set(blockchain.ux.dashboard.trading.assets.fiat, to: result)
            }
            .store(in: &cancellables)

        app.publisher(for: blockchain.ux.dashboard.defi.assets.info, as: AssetBalanceInfoResult.self)
            .compactMap(\.value)
            .flatMapLatest { [priceService] result -> AnyPublisher<Result<BalanceInfo, BalanceInfoError>, Never> in
                let cryptoBalances: [CryptoValue] = result.info.compactMap { $0.balance?.cryptoValue }
                let fiatCurrency: FiatCurrency = result.fiatCurrency
                return priceService.prices(
                    cryptoCurrencies: cryptoBalances.map(\.currency).unique,
                    fiatCurrency: fiatCurrency,
                    at: .oneDay
                )
                .map { prices -> Result<BalanceInfo, BalanceInfoError> in
                    let balancesYesterday: [MoneyValue] = cryptoBalances.compactMap { balance in
                        let fiatPrice = prices[balance.currency]
                        if let fiatPrice {
                            return MoneyValuePair(
                                base: balance.moneyValue,
                                exchangeRate: fiatPrice.moneyValue
                            ).quote
                        } else {
                            return nil
                        }
                    }
                    let balancesNow: [MoneyValue] = result.info.compactMap(\.fiatBalance?.quote)
                    do {
                        let totalBalanceNow: MoneyValue = try balancesNow
                            .reduce(MoneyValue.zero(currency: fiatCurrency), +)
                        let totalBalanceYesterday: MoneyValue = try balancesYesterday
                            .reduce(MoneyValue.zero(currency: fiatCurrency), +)
                        let info: BalanceInfo = try balanceInfoBetween(
                            currentBalance: totalBalanceNow,
                            previousBalance: totalBalanceYesterday
                        )
                        return .success(info)
                    } catch {
                        return .failure(BalanceInfoError.unableToRetrieve)
                    }
                }
                .eraseToAnyPublisher()
            }
            .sink { [app] balanceInfo in
                switch balanceInfo {
                case .success(let info):
                    app.state.set(blockchain.ux.dashboard.total.defi.balance, to: info)
                case .failure(let error):
                    app.post(error: error)
                }
            }
            .store(in: &cancellables)

        app.publisher(for: blockchain.ux.dashboard.trading.assets.crypto, as: AssetBalanceInfoResult.self)
            .compactMap(\.value)
            .combineLatest(app.publisher(for: blockchain.ux.dashboard.trading.assets.fiat, as: FiatBalanceInfoResult.self).compactMap(\.value))
            .map { tradingAssetsInfo, fiatBalanceInfo -> Result<BalanceInfo, BalanceInfoError> in
                let fiatCurrency = tradingAssetsInfo.fiatCurrency
                let allCustodial: [MoneyValue] = tradingAssetsInfo.info.compactMap { $0.fiatBalance?.quote }
                let allFiat: [MoneyValue] = fiatBalanceInfo.info.balances.compactMap { $0.fiatBalance?.quote }
                let total = allCustodial + allFiat

                let yesterdayAllCustodial: [MoneyValue] = tradingAssetsInfo.info.compactMap { $0.yesterdayFiatBalance?.quote }
                let yesterdayTotal = yesterdayAllCustodial + allFiat
                do {
                    let totalBalance: MoneyValue = try total.reduce(MoneyValue.zero(currency: fiatCurrency), +)
                    let totalBalanceYesterday: MoneyValue = try yesterdayTotal.reduce(MoneyValue.zero(currency: fiatCurrency), +)
                    let info = try balanceInfoBetween(currentBalance: totalBalance, previousBalance: totalBalanceYesterday)
                    return .success(info)
                } catch {
                    return .failure(.unableToRetrieve)
                }
            }
            .sink { [app] balanceInfo in
                switch balanceInfo {
                case .success(let info):
                    app.state.set(blockchain.ux.dashboard.total.trading.balance.info, to: info)
                case .failure(let error):
                    app.post(error: error)
                }
            }
            .store(in: &cancellables)

        app.publisher(for: blockchain.ux.dashboard.total.trading.balance.info, as: BalanceInfo.self)
            .compactMap(\.value)
            .combineLatest(app.publisher(for: blockchain.ux.dashboard.total.defi.balance, as: BalanceInfo.self).compactMap(\.value))
            .sink { [app] tradingInfo, defiInfo in
                do {
                    let total = try tradingInfo.balance + defiInfo.balance
                    app.state.set(blockchain.ux.dashboard.total.balance, to: total)
                } catch {
                    app.post(error: error)
                }
            }
            .store(in: &cancellables)
    }

    public func stop() {
        lifetimeBag = []
    }
}

// MARK: - Models

public enum AssetBalanceInfoError: Error, Codable, Hashable, Equatable {
    case failure
    case unableToRetrieve
}

public struct AssetBalanceInfoResult: Codable, Hashable, Equatable {
    public let info: [AssetBalanceInfo]
    public let fiatCurrency: FiatCurrency
    public let hasError: Bool
}

public struct FiatBalanceInfoResult: Codable, Hashable, Equatable {
    public let info: FiatBalancesInfo
    public let hasError: Bool
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
