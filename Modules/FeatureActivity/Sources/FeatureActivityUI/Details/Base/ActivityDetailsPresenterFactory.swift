// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ERC20Kit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

enum ActivityDetailsPresenterFactory {

    static func presenter(
        for event: ActivityItemEvent,
        router: ActivityRouterAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) -> DetailsScreenPresenterAPI {
        switch event {
        case .interest(let interest):
            return InterestActivityDetailsPresenter(event: interest)
        case .earn(let product, let staking):
            return StakingActivityDetailsPresenter(product: product, event: staking)
        case .fiat(let fiat):
            return FiatActivityDetailsPresenter(event: fiat)
        case .crypto(let crypto):
            return CryptoActivityDetailsPresenter(event: crypto)
        case .buySell(let event):
            let interactor = BuySellActivityDetailsInteractor(
                cardDataService: resolve(),
                ordersService: resolve(),
                recurringBuyProviderRepository: resolve()
            )
            return BuySellActivityDetailsPresenter(
                event: event,
                interactor: interactor,
                analyticsRecorder: resolve()
            )
        case .swap(let swap):
            return SwapActivityDetailsPresenter(event: swap)
        case .transactional(let transactional):
            return Self.presenter(
                transactional: transactional,
                router: router,
                enabledCurrenciesService: enabledCurrenciesService
            )
        case .simpleTransactional(let event):
            let interactor = SimpleActivityDetailsInteractor(
                fiatCurrencySettings: resolve(),
                priceService: resolve()
            )
            return SimpleActivityDetailsPresenter(
                event: event,
                interactor: interactor,
                alertViewPresenter: resolve(),
                analyticsRecorder: resolve()
            )
        }
    }

    private static func presenter(
        transactional: TransactionalActivityItemEvent,
        router: ActivityRouterAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) -> DetailsScreenPresenterAPI {
        let cryptoCurrency = transactional.currency
        switch cryptoCurrency {
        case .bitcoin:
            return BitcoinActivityDetailsPresenter(event: transactional, router: router)
        case .bitcoinCash:
            return BitcoinCashActivityDetailsPresenter(event: transactional, router: router)
        case .stellar:
            return StellarActivityDetailsPresenter(event: transactional, router: router)
        case let asset where asset.isERC20:
            guard let parentEVMNetwork = evmNetwork(enabledCurrenciesService: enabledCurrenciesService, cryptoCurrency: cryptoCurrency) else {
                fatalError("Misconfigured")
            }
            let interactor = ERC20ActivityDetailsInteractor(cryptoCurrency: cryptoCurrency, network: parentEVMNetwork)
            return ERC20ActivityDetailsPresenter(event: transactional, router: router, interactor: interactor)
        default:
            if let network = evmNetwork(enabledCurrenciesService: enabledCurrenciesService, cryptoCurrency: cryptoCurrency) {
                let interactor = EthereumActivityDetailsInteractor(cryptoCurrency: cryptoCurrency, network: network)
                return EthereumActivityDetailsPresenter(event: transactional, router: router, interactor: interactor)
            }
            fatalError("Transactional Activity Details not implemented for \(cryptoCurrency.code).")
        }
    }

    private static func evmNetwork(enabledCurrenciesService: EnabledCurrenciesServiceAPI, cryptoCurrency: CryptoCurrency) -> EVMNetwork? {
        enabledCurrenciesService.network(for: cryptoCurrency)
    }
}
