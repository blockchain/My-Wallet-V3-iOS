// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableNavigation
import Foundation
import MoneyKit

struct PriceReducer: Reducer {

    typealias State = Price
    typealias Action = PriceAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let priceService: PriceServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        priceService: PriceServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.priceService = priceService
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .currencyDidAppear:
                guard state.value == .loading else {
                    return .none
                }
                return .run { [currency = state.currency] send in
                    let priceSeries = try await priceService
                        .priceSeries(of: currency, in: FiatCurrency.USD, within: .day(.oneHour))
                        .await()
                    if let latestPrice = priceSeries.prices.last {
                        await send(
                            .priceValuesDidLoad(
                                price: latestPrice.moneyValue.displayString,
                                delta: priceSeries.deltaPercentage.doubleValue
                            )
                        )
                    }
                }
                .cancellable(id: state.currency.code)

            case .currencyDidDisappear:
                return .cancel(id: state.currency)

            case .priceValuesDidLoad(let price, let delta):
                state.value = .loaded(next: price)
                state.deltaPercentage = .loaded(next: delta)
                return .none

            case .none:
                return .none
            }
        }
    }
}
