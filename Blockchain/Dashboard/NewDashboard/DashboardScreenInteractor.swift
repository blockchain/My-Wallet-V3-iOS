//
//  DashboardScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardScreenInteractor {
    
    // MARK: - Services
    
    let balanceProvider: BalanceProviding
    let historicalProvider: HistoricalFiatPriceProviding
    let balanceChangeProvider: BalanceChangeProviding
    let reactiveWallet: ReactiveWalletAPI
    let userPropertyInteractor: AnalyticsUserPropertyInteractor
    
    let historicalBalanceInteractors: [HistoricalBalanceCellInteractor]
    let fiatBalancesInteractor: DashboardFiatBalancesInteractor
    let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    
    var enabledCryptoCurrencies: [CryptoCurrency] {
        enabledCurrenciesService.allEnabledCryptoCurrencies
    }
    
    // MARK: - Private Accessors
    
    private let disposeBag = DisposeBag()
    
    init(tiersService: KYCTiersServiceAPI = resolve(),
         balanceProvider: BalanceProviding = DataProvider.default.balance,
         historicalProvider: HistoricalFiatPriceProviding = DataProvider.default.historicalPrices,
         balanceChangeProvider: BalanceChangeProviding = DataProvider.default.balanceChange,
         paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
         enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
         featureFetcher: FeatureFetching = resolve(),
         reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet,
         userPropertyInteractor: AnalyticsUserPropertyInteractor = AnalyticsUserPropertyInteractor(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.historicalProvider = historicalProvider
        self.balanceProvider = balanceProvider
        self.balanceChangeProvider = balanceChangeProvider
        self.reactiveWallet = reactiveWallet
        self.enabledCurrenciesService = enabledCurrenciesService
        self.userPropertyInteractor = userPropertyInteractor
        historicalBalanceInteractors = enabledCurrenciesService.allEnabledCryptoCurrencies.map {
            HistoricalBalanceCellInteractor(
                cryptoCurrency: $0,
                historicalFiatPriceService: historicalProvider[$0],
                assetBalanceFetcher: balanceProvider[$0.currency]
            )
        }
        fiatBalancesInteractor = DashboardFiatBalancesInteractor(
            tiersService: tiersService,
            balanceProvider: balanceProvider,
            featureFetcher: featureFetcher,
            paymentMethodsService: paymentMethodsService,
            enabledCurrenciesService: enabledCurrenciesService,
            fiatCurrencyService: fiatCurrencyService
        )
        
        NotificationCenter.when(.walletInitialized) { [weak self] _ in
            self?.refresh()
        }
    }
    
    func refresh() {
        reactiveWallet.waitUntilInitialized
            .bind { [weak self] _ in
                guard let self = self else { return }
                
                /// Refresh dashboard interaction layer
                self.historicalProvider.refresh(window: .day(.oneHour))
                self.balanceProvider.refresh()
                
                /// Record user properties once wallet is initialized
                self.userPropertyInteractor.record()
            }
            .disposed(by: disposeBag)
    }
}
