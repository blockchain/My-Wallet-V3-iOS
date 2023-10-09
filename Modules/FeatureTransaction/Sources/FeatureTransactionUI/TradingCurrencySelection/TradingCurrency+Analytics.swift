// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import MoneyKit

extension AnalyticsEvents.New {

    enum TradingCurrency: AnalyticsEvent {

        case fiatCurrencySelected(currency: String)

        var type: AnalyticsEventType {
            .nabu
        }
    }
}

struct TradingCurrencyAnalyticsReducer: ReducerProtocol {
    
    typealias State = TradingCurrency.State
    typealias Action = TradingCurrency.Action

    let analyticsRecorder: AnalyticsEventRecorderAPI

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didSelect(let currency):
                return .fireAndForget {
                    analyticsRecorder.record(
                        event: AnalyticsEvents.New.TradingCurrency.fiatCurrencySelected(currency: currency.code)
                    )
                }

            default:
                return .none
            }
        }
    }
}
