// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableNavigation
import Foundation
import MoneyKit

struct PriceReducer: ReducerProtocol {
    
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

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .currencyDidAppear:
                guard state.value == .loading else {
                    return .none
                }
                return priceService
                    .priceSeries(of: state.currency, in: FiatCurrency.USD, within: .day(.oneHour))
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .cancellable(id: state.currency.code)
                    .map { result in
                        guard case .success(let priceSeries) = result, let latestPrice = priceSeries.prices.last else {
                            return .none
                        }
                        return .priceValuesDidLoad(
                            price: latestPrice.moneyValue.displayString,
                            delta: priceSeries.deltaPercentage.doubleValue
                        )
                    }

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
