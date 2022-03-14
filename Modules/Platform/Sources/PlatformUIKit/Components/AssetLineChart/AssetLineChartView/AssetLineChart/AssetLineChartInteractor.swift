// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetLineChartInteractor: AssetLineChartInteracting {

    // MARK: - Properties

    public var state: Observable<AssetLineChart.State.Interaction> {
        _ = setup
        return stateRelay
            .asObservable()
    }

    private var window: Signal<PriceWindow> {
        priceWindowRelay
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: .day(.oneHour))
    }

    public let priceWindowRelay = PublishRelay<PriceWindow>()

    // MARK: - Private Accessors

    private lazy var setup: Void = window
        .emit(onNext: { [weak self] priceWindow in
            self?.loadHistoricalPrices(within: priceWindow)
        })
        .disposed(by: disposeBag)

    private let stateRelay = BehaviorRelay<AssetLineChart.State.Interaction>(value: .loading)
    private let cryptoCurrency: CryptoCurrency
    private let priceService: PriceServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        cryptoCurrency: CryptoCurrency,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        priceService: PriceServiceAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.cryptoCurrency = cryptoCurrency
    }

    private func loadHistoricalPrices(within window: PriceWindow) {
        fiatCurrencyService
            .displayCurrencyPublisher
            .flatMap { [priceService, cryptoCurrency] fiatCurrency in
                priceService
                    .priceSeries(of: cryptoCurrency, in: fiatCurrency, within: window)
            }
            .map { [cryptoCurrency] priceSeries in
                AssetLineChart.Value.Interaction(
                    delta: priceSeries.delta,
                    currency: cryptoCurrency,
                    prices: priceSeries.prices
                )
            }
            .map(AssetLineChart.State.Interaction.loaded)
            .asObservable()
            .startWith(.loading)
            .catchAndReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
