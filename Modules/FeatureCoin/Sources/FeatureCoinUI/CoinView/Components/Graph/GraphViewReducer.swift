// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain

public let graphViewReducer = Reducer<
    GraphViewState,
    GraphViewAction,
    CoinViewEnvironment
> { state, action, environment in
    struct FetchID: Hashable {}
    switch action {
    case .onAppear(let context):
        let series = (
            environment.app.state
                .result(for: blockchain.ux.asset.chart.interval[].ref(to: context))
                .value as? Series
        ) ?? state.interval
        return EffectTask(value: .request(series, force: true))
    case .request(let interval, let force):
        guard force || interval != state.interval else {
            return .none
        }
        state.isFetching = true
        state.interval = interval
        return .merge(
            .cancel(id: FetchID()),
            environment.historicalPriceService.fetch(
                series: interval,
                relativeTo: state.date
            )
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(GraphViewAction.fetched)
            .cancellable(id: FetchID())
        )
    case .fetched(let data):
        state.result = data
        state.isFetching = false
        return .none
    case .binding:
        return .none
    }
}
.binding()
