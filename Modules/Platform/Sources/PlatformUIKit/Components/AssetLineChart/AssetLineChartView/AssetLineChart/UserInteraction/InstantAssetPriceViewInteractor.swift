// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// `InstantAssetPriceViewInteractor` is an `AssetPriceViewInteracting`
/// that takes a `AssetLineChartUserInteracting`. This allows the view to be
/// updated with price selections as the user interacts with the `LineChartView`
public final class InstantAssetPriceViewInteractor: AssetPriceViewInteracting {

    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction

    // MARK: - Exposed Properties

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
            .observe(on: MainScheduler.instance)
    }

    public func refresh() {}

    // MARK: - Private Accessors

    private lazy var setup: Void = Observable
        .combineLatest(
            historicalPriceProvider.calculationState,
            chartUserInteracting.state
        )
        .map { tuple -> InteractionState in
            let calculationState = tuple.0
            let userInteractionState = tuple.1

            switch (calculationState, userInteractionState) {
            case (.calculating, _),
                 (.invalid, _):
                return .loading
            case (.value(let result), .deselected):
                let delta = result.historicalPrices.delta
                let currency = result.historicalPrices.currency
                let window = result.priceWindow
                let currentPrice = result.currentFiatValue
                let priceChange = FiatValue(
                    amount: result.historicalPrices.fiatChange,
                    currency: result.currentFiatValue.currency
                )
                return .loaded(
                    next: .init(
                        currentPrice: currentPrice.moneyValue,
                        time: window.time(for: currency),
                        changePercentage: delta.doubleValue,
                        priceChange: priceChange.moneyValue
                    )
                )
            case (.value(let result), .selected(let index)):
                let historicalPrices = result.historicalPrices
                let currentFiatValue = result.currentFiatValue
                let prices = Array(historicalPrices.prices[0...min(index, historicalPrices.prices.count - 1)])
                let fiatCurrency = currentFiatValue.currency
                guard let selected = prices.last else { return .loading }
                let adjusted = HistoricalPriceSeries(currency: historicalPrices.currency, prices: prices)

                let priceChange = FiatValue(amount: adjusted.fiatChange, currency: fiatCurrency)

                return .loaded(
                    next: .init(
                        currentPrice: selected.moneyValue,
                        time: .timestamp(selected.timestamp),
                        changePercentage: adjusted.delta.doubleValue,
                        priceChange: priceChange.moneyValue
                    )
                )
            }
        }
        .catchAndReturn(.loading)
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    private let historicalPriceProvider: HistoricalFiatPriceServiceAPI
    private let chartUserInteracting: AssetLineChartUserInteracting

    // MARK: - Setup

    public init(
        historicalPriceProvider: HistoricalFiatPriceServiceAPI,
        chartUserInteracting: AssetLineChartUserInteracting
    ) {
        self.historicalPriceProvider = historicalPriceProvider
        self.chartUserInteracting = chartUserInteracting
    }
}
