//
//  DataProvider.swift
//  TodayExtension
//
//  Created by Alex McGregor on 6/17/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class UserInformationService: FiatCurrencyServiceAPI {
    
    var legacyCurrency: FiatCurrency? {
        .USD
    }
    
    var fiatCurrencyObservable: Observable<FiatCurrency> {
        fiatCurrency.asObservable()
    }
    
    var fiatCurrency: Single<FiatCurrency> {
        let code = Locale.current.currencyCode ?? "USD"
        let currency = FiatCurrency.init(code: code) ?? .USD
        return Single.just(currency)
    }
}

final class DataProvider {
    
    /// The default container
    static let `default` = DataProvider()
    
    /// Historical service that provides past prices for a given asset type
    let historicalPrices: HistoricalFiatPriceProviding
    
    /// Exchange service for any asset
    let exchange: ExchangeProviding
    
    init(fiatCurrencyService: FiatCurrencyServiceAPI = UserInformationService()) {
        
        var cryptoExchangeServices: [CryptoCurrency: PairExchangeServiceAPI] = [:]
        for cryptoCurrency in CryptoCurrency.allCases {
            cryptoExchangeServices[cryptoCurrency] = PairExchangeService(
                currency: cryptoCurrency,
                fiatCurrencyService: fiatCurrencyService
            )
        }
        var fiatExchangeServices: [FiatCurrency: PairExchangeServiceAPI] = [:]
        for fiatCurrency in [FiatCurrency.GBP, FiatCurrency.EUR] {
            fiatExchangeServices[fiatCurrency] = PairExchangeService(
                currency: fiatCurrency,
                fiatCurrencyService: fiatCurrencyService
            )
        }
        
        self.exchange = ExchangeProvider(
            fiats: fiatExchangeServices,
            cryptos: cryptoExchangeServices
        )

        let aaveHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .aave,
            exchangeAPI: exchange[CryptoCurrency.aave],
            fiatCurrencyService: fiatCurrencyService
        )
        let algorandHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .algorand,
            exchangeAPI: exchange[CryptoCurrency.algorand],
            fiatCurrencyService: fiatCurrencyService
        )
        let bitcoinHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoin,
            exchangeAPI: exchange[CryptoCurrency.bitcoin],
            fiatCurrencyService: fiatCurrencyService
        )
        let bitcoinCashHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoinCash,
            exchangeAPI: exchange[CryptoCurrency.bitcoinCash],
            fiatCurrencyService: fiatCurrencyService
        )
        let etherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .ethereum,
            exchangeAPI: exchange[CryptoCurrency.ethereum],
            fiatCurrencyService: fiatCurrencyService
        )
        let paxHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .pax,
            exchangeAPI: exchange[CryptoCurrency.pax],
            fiatCurrencyService: fiatCurrencyService
        )
        let polkadotHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .polkadot,
            exchangeAPI: exchange[CryptoCurrency.polkadot],
            fiatCurrencyService: fiatCurrencyService
        )
        let stellarHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .stellar,
            exchangeAPI: exchange[CryptoCurrency.stellar],
            fiatCurrencyService: fiatCurrencyService
        )
        let tetherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .tether,
            exchangeAPI: exchange[CryptoCurrency.tether],
            fiatCurrencyService: fiatCurrencyService
        )
        let wDGLDHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .wDGLD,
            exchangeAPI: exchange[CryptoCurrency.wDGLD],
            fiatCurrencyService: fiatCurrencyService
        )
        let yearnFinanceHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .yearnFinance,
            exchangeAPI: exchange[CryptoCurrency.yearnFinance],
            fiatCurrencyService: fiatCurrencyService
        )

        self.historicalPrices = HistoricalFiatPriceProvider(
            aave: aaveHistoricalFiatService,
            algorand: algorandHistoricalFiatService,
            bitcoin: bitcoinHistoricalFiatService,
            bitcoinCash: bitcoinCashHistoricalFiatService,
            ether: etherHistoricalFiatService,
            pax: paxHistoricalFiatService,
            polkadot: polkadotHistoricalFiatService,
            stellar: stellarHistoricalFiatService,
            tether: tetherHistoricalFiatService,
            wDGLD: wDGLDHistoricalFiatService,
            yearnFinance: yearnFinanceHistoricalFiatService
        )
    }
}
