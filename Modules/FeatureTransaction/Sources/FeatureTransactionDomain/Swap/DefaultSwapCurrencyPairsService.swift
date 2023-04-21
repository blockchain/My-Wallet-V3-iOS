// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation
import MoneyKit
import PlatformKit

public protocol DefaultSwapCurrencyPairsServiceAPI {
    func getDefaultPairs() async -> (source: CryptoCurrency, target: CryptoCurrency)?
}

public class DefaultSwapCurrencyPairsService: DefaultSwapCurrencyPairsServiceAPI {
    private let app: AppProtocol

    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public func getDefaultPairs() async -> (source: MoneyDomainKit.CryptoCurrency, target: MoneyDomainKit.CryptoCurrency)? {
        let appMode = await app.mode()

        switch appMode {
        case .trading, .universal:
            return await getDefaultTradingPairs()
        case .pkw:
            return await getDefaultNonCustodialPairs()
        }
    }

    private func getDefaultTradingPairs() async -> (source: MoneyDomainKit.CryptoCurrency, target: MoneyDomainKit.CryptoCurrency)? {
        do {
            let custodialCurrencies = try await app.get(blockchain.user.trading.currencies, as: [String].self)
            let balance = try await custodialCurrencies
                .async
                .map { currency -> MoneyValuePair in
                    try await MoneyValuePair(
                        base: self.app.get(blockchain.user.trading.account[currency].balance.available),
                        exchangeRate: self.app.get(blockchain.api.nabu.gateway.price.at.time[PriceTime.now.id].crypto[currency].fiat.quote.value)
                    )
                }
                .reduce(into: []) { balances, moneyValuePair in
                    balances.append(moneyValuePair)
                }
                .sorted(by: { try $0.quote > $1.quote })
                .first.or(throw: "No matching pairs")

            guard let currency = balance.base.currency.cryptoCurrency else { throw "Not a cryptocurrency" }
            if currency.code == CryptoCurrency.bitcoin.code {
                return (source: CryptoCurrency.bitcoin, target: CryptoCurrency.usdt)
            } else {
                return (source: currency, target: CryptoCurrency.bitcoin)
            }

        } catch {
            return nil
        }
    }

    private func getDefaultNonCustodialPairs() async -> (source: MoneyDomainKit.CryptoCurrency, target: MoneyDomainKit.CryptoCurrency)? {
        do {
            let nonCustodialCurrencies = try await app.get(blockchain.user.pkw.currencies, as: [String].self)
            let balance = try await nonCustodialCurrencies
                .async
                .map { currency -> MoneyValuePair in
                    try await MoneyValuePair(
                        base: self.app.get(blockchain.user.pkw.asset[currency].balance),
                        exchangeRate: self.app.get(blockchain.api.nabu.gateway.price.at.time[PriceTime.now.id].crypto[currency].fiat.quote.value)
                    )
                }
                .reduce(into: []) { balances, moneyValuePair in
                    balances.append(moneyValuePair)
                }
                .sorted(by: { try $0.quote > $1.quote })
                .first.or(throw: "No matching pairs")

            guard let currency = balance.base.currency.cryptoCurrency else { throw "Not a cryptocurrency" }
            if currency.code == CryptoCurrency.bitcoin.code {
                return (source: CryptoCurrency.bitcoin, target: CryptoCurrency.usdt)
            } else {
                return (source: currency, target: CryptoCurrency.bitcoin)
            }
        } catch {
            return nil
        }
    }
}
