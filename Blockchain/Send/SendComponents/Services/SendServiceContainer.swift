//
//  SendServiceContainer.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import Foundation
import PlatformKit

protocol SendServiceContaining {
    var asset: CryptoCurrency { get }
    var sourceAccountProvider: SendSourceAccountProviding { get }
    var sourceAccountState: SendSourceAccountStateServicing { get }
    var exchangeAddressFetcher: ExchangeAddressFetching { get }
    var executor: SendExecuting { get }
    var exchange: PairExchangeServiceAPI { get }
    var fee: SendFeeServicing { get }
    var balance: SingleAccountBalanceFetching { get }
    var bus: WalletActionEventBus { get }
    var fiatCurrency: FiatCurrencySettingsServiceAPI { get }
    
    /// Performs any necessary cleaning to the service layer.
    /// In order to change asset in the future, we will only replace `asset: CryptoCurrency`
    /// which will force the interaction & presentation to change accordingly.
    /// Adopting this approach, only 1 VIPER will be needed.
    func clean()
}

struct SendServiceContainer: SendServiceContaining {
    let asset: CryptoCurrency
    let sourceAccountProvider: SendSourceAccountProviding
    let sourceAccountState: SendSourceAccountStateServicing
    let exchangeAddressFetcher: ExchangeAddressFetching
    let executor: SendExecuting
    let exchange: PairExchangeServiceAPI
    let fee: SendFeeServicing
    let balance: SingleAccountBalanceFetching
    let bus: WalletActionEventBus
    let fiatCurrency: FiatCurrencySettingsServiceAPI
    
    init(asset: CryptoCurrency) {
        self.asset = asset
        exchangeAddressFetcher = ExchangeAddressFetcher()
        executor = SendExecutor(asset: asset)
        fee = SendFeeService(asset: asset)
        sourceAccountState = SendSourceAccountStateService(asset: asset)
        bus = WalletActionEventBus()
        fiatCurrency = resolve()
        
        switch asset {
        case .ethereum:
            exchange = DataProvider.default.exchange[CurrencyType.crypto(.ethereum)]
            sourceAccountProvider = EtherSendSourceAccountProvider()
            balance = { () -> CryptoAccountBalanceFetching in resolve(tag: asset) }()
        case .aave,
             .algorand,
             .bitcoin,
             .bitcoinCash,
             .pax,
             .polkadot,
             .stellar,
             .tether,
             .wDGLD,
             .yearnFinance:
            fatalError("\(#function) is not implemented for \(asset)")
        }
    }
    
    func clean() {
        sourceAccountState.recalculateState()
        fee.triggerRelay.accept(Void())
        exchange.fetchTriggerRelay.accept(Void())
        executor.fetchHistoryIfNeeded()
    }
}
