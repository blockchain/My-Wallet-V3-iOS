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
    switch action {
    case .onAppear(let context):
        let interval: Series = defaultInterval(environment.app, context) ?? state.interval
        return EffectTask(value: .request(interval, force: true))
    case .request(let interval, let force):
        guard force || interval != state.interval else {
            return .none
        }
        state.isFetching = true
        state.interval = interval
        return environment.historicalPriceService.fetch(
            series: interval,
            relativeTo: state.date
        )
        .receive(on: environment.mainQueue)
        .catchToEffect(GraphViewAction.fetched)
        .cancellable(id: GraphViewCancellable.fetch)
    case .fetched(let data):
        state.result = data
        state.isFetching = false
        return .none
    case .binding:
        return .none
    }
}
.binding()

private enum GraphViewCancellable {
    case fetch
}

private func defaultInterval(_ app: AppProtocol, _ context: Tag.Context) -> Series? {
    app.state
        .result(for: blockchain.ux.asset.chart.interval[].ref(to: context))
        .value as? Series
}
