//
//  MockSendServiceContainer.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

@testable import Blockchain

struct MockSendServiceContainer: SendServiceContaining {
    let asset: CryptoCurrency
    let sourceAccountProvider: SendSourceAccountProviding
    var sourceAccountState: SendSourceAccountStateServicing
    let exchangeAddressFetcher: ExchangeAddressFetching
    let executor: SendExecuting
    let exchange: PairExchangeServiceAPI
    let fee: SendFeeServicing
    let balance: SingleAccountBalanceFetching
    let bus: WalletActionEventBus
    let fiatCurrency: FiatCurrencySettingsServiceAPI
    
    init(asset: CryptoCurrency,
         balance: CryptoValue,
         fee: CryptoValue,
         exchange: FiatValue,
         fiatCurrency: FiatCurrencySettingsServiceAPI,
         sourceAccountStateValue: SendSourceAccountState,
         pitAddressFetchResult: Result<ExchangeAddressFetcher.AddressResponseBody.State, ExchangeAddressFetcher.FetchingError>,
         transferExecutionResult: Result<Void, Error>) {
        self.asset = asset
        exchangeAddressFetcher = MockExchangeAddressFetcher(expectedResult: pitAddressFetchResult)
        executor = MockSendExecutor(expectedResult: transferExecutionResult)
        self.exchange = MockPairExchangeService(expectedValue: exchange)
        self.fee = MockSendFeeService(expectedValue: fee)
        sourceAccountState = MockSendSourceAccountStateService(stateRawValue: sourceAccountStateValue)
        bus = WalletActionEventBus()
        self.fiatCurrency = fiatCurrency
        switch asset {
        case .ethereum:
            sourceAccountProvider = EtherSendSourceAccountProvider()
            self.balance = MockAccountBalanceFetcher(expectedBalance: MoneyValue(cryptoValue: balance))
        default:
            fatalError("\(#function) is not implemented for \(asset)")
        }
    }
    
    func clean() { }
}
