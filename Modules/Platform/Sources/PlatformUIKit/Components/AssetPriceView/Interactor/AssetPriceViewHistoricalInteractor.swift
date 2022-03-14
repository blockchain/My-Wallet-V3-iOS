// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

/// Implementation of `AssetPriceViewInteracting` that streams a State based on the given
/// HistoricalFiatPriceService state.
public final class AssetPriceViewHistoricalInteractor: AssetPriceViewInteracting {

    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction

    // MARK: - Exposed Properties

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay
            .asObservable()
            .observe(on: MainScheduler.instance)
    }

    public func refresh() {}

    // MARK: - Private Accessors

    private lazy var setup: Void = historicalPriceProvider.calculationState
        .map { state -> InteractionState in
            switch state {
            case .calculating, .invalid:
                return .loading
            case .value(let result):
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
            }
        }
        .catchAndReturn(.loading)
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    private let historicalPriceProvider: HistoricalFiatPriceServiceAPI

    // MARK: - Setup

    public init(historicalPriceProvider: HistoricalFiatPriceServiceAPI) {
        self.historicalPriceProvider = historicalPriceProvider
    }
}
