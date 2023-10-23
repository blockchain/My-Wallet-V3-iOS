// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import FeatureCoinDomain

public struct GraphViewReducer: Reducer {
    enum CancellableID: Hashable {
        case fetch
    }

    public typealias State = GraphViewState
    public typealias Action = GraphViewAction

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.app) var app
    let historicalPriceService: HistoricalPriceService

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear(let context):
                let interval: Series = defaultInterval(app, context) ?? state.interval
                return Effect.send(.request(interval, force: true))
            case .request(let interval, let force):
                guard force || interval != state.interval else {
                    return .none
                }
                state.isFetching = true
                state.interval = interval
                return .publisher { [date = state.date] in
                    historicalPriceService.fetch(
                        series: interval,
                        relativeTo: date
                    )
                    .receive(on: mainQueue)
                    .map { .fetched(.success($0)) }
                    .catch { .fetched(.failure($0)) }
                }
                .cancellable(id: CancellableID.fetch)
            case .fetched(let data):
                state.result = data
                state.isFetching = false
                return .none
            case .binding:
                return .none
            }
        }
    }
}

private func defaultInterval(_ app: AppProtocol, _ context: Tag.Context) -> Series? {
    app.state
        .result(for: blockchain.ux.asset.chart.interval[].ref(to: context))
        .value as? Series
}
