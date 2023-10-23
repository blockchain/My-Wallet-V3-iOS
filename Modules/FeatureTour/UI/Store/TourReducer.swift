// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureTourDomain
import MoneyKit
import SwiftUI

public struct TourReducer: Reducer {

    public typealias State = TourState
    public typealias Action = TourAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    let priceService: PriceServiceAPI

    var createAccountAction: () -> Void
    var restoreAction: () -> Void
    var logInAction: () -> Void
    var manualLoginAction: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        priceService: PriceServiceAPI,
        createAccountAction: @escaping () -> Void,
        restoreAction: @escaping () -> Void,
        logInAction: @escaping () -> Void,
        manualLoginAction: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.enabledCurrenciesService = enabledCurrenciesService
        self.createAccountAction = createAccountAction
        self.restoreAction = restoreAction
        self.logInAction = logInAction
        self.manualLoginAction = manualLoginAction
        self.priceService = priceService
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .createAccount:
                createAccountAction()
                return .none
            case .didChangeStep(let newStep):
                state.visibleStep = newStep
                if newStep != .prices {
                    state.scrollOffset = 0
                }
                return .none
            case .restore:
                restoreAction()
                return .none
            case .logIn:
                logInAction()
                return .none
            case .manualLogin:
                manualLoginAction()
                return .none
            case .price:
                return .none
            case .priceListDidScroll(let offset):
                state.scrollOffset = offset
                return .none
            case .loadPrices:
                let currencies = enabledCurrenciesService.allEnabledCryptoCurrencies
                state.items = IdentifiedArray(uniqueElements: currencies.map { Price(currency: $0) })
                return .none
            case .none:
                return .none
            }
        }
//        .forEach(\.items, action: /Action.price(id:action:)) {
//            PriceReducer(priceService: priceService)
//        }
    }
}

struct NoOpReducer: Reducer {
    typealias State = TourState
    typealias Action = TourAction

    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}
