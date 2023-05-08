// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Foundation
import MoneyKit
import PlatformKit

public struct SelectionInformation: Equatable {
    public init(accountId: String, currency: CryptoCurrency) {
        self.accountId = accountId
        self.currency = currency
    }

    public var accountId: String
    public var currency: CryptoCurrency
}

public protocol DefaultSwapCurrencyPairsServiceAPI {
    func getDefaultPairs() async -> (source: SelectionInformation, target: SelectionInformation)?
}

public class DefaultSwapCurrencyPairsService: DefaultSwapCurrencyPairsServiceAPI {
    private let app: AppProtocol

    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public func getDefaultPairs() async -> (source: SelectionInformation, target: SelectionInformation)? {
        let appMode = await app.mode()

        switch appMode {
        case .trading, .universal:
            return await getDefaultTradingPairs()
        case .pkw:
            return await getDefaultNonCustodialPairs()
        }
    }

    private func getDefaultTradingPairs() async -> (source: SelectionInformation, target: SelectionInformation)? {
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

            guard let accountId = try? await app.get(blockchain.coin.core.accounts.custodial.asset[currency.code], as: String.self) else {
                throw "No account id found"
            }
            guard let bitcoinAccountId = try? await app.get(blockchain.coin.core.accounts.custodial.asset[CryptoCurrency.bitcoin.code], as: String.self) else {
                throw "No account id found"
            }
            guard let usdtAccountId = try? await app.get(blockchain.coin.core.accounts.custodial.asset[CryptoCurrency.usdt.code], as: String.self) else {
                throw "No account id found"
            }

            if currency.code == CryptoCurrency.bitcoin.code {
                return (SelectionInformation(accountId: bitcoinAccountId, currency: CryptoCurrency.bitcoin), SelectionInformation(accountId: usdtAccountId, currency: CryptoCurrency.usdt))
            } else {
                return (SelectionInformation(accountId: accountId, currency: currency), SelectionInformation(accountId: bitcoinAccountId, currency: CryptoCurrency.bitcoin))
            }
        } catch {
            return nil
        }
    }

    private func getDefaultNonCustodialPairs() async -> (source: SelectionInformation, target: SelectionInformation)? {
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
            guard let accountId = try? await app.get(blockchain.coin.core.accounts.DeFi.asset[currency.code], as: [String].self).first else {
                throw "No account id found"
            }
            guard let bitcoinAccountId = try? await app.get(blockchain.coin.core.accounts.DeFi.asset[CryptoCurrency.bitcoin.code], as: [String].self).first else {
                throw "No account id found"
            }
            guard let usdtAccountId = try? await app.get(blockchain.coin.core.accounts.DeFi.asset[CryptoCurrency.usdt.code], as: [String].self).first else {
                throw "No account id found"
            }

            if currency.code == CryptoCurrency.bitcoin.code {
                return (
                    SelectionInformation(accountId: bitcoinAccountId, currency: CryptoCurrency.bitcoin),
                    SelectionInformation(accountId: usdtAccountId, currency: CryptoCurrency.usdt)
                )
            } else {
                return (
                    SelectionInformation(accountId: accountId, currency: currency),
                    SelectionInformation(accountId: bitcoinAccountId, currency: CryptoCurrency.bitcoin)
                )
            }
        } catch {
            return nil
        }
    }

    private func pair(with currency: CurrencyType) throws -> (source: CryptoCurrency, target: CryptoCurrency) {
        guard let cryptoCurrency = currency.cryptoCurrency else {
            throw "Not a cryptocurrency"
        }
        return (source: cryptoCurrency, target: target(for: cryptoCurrency))
    }

    private func target(
        for cryptoCurrency: CryptoCurrency,
        currenciesService: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default
    ) -> CryptoCurrency {
        let bitcoin = CryptoCurrency.bitcoin
        if cryptoCurrency == bitcoin {
            let usdt = currenciesService.allEnabledCryptoCurrencies.first(where: { $0.code == "USDT" })
            return usdt ?? CryptoCurrency.ethereum
        } else {
            return bitcoin
        }
    }
}
