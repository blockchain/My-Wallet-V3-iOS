// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Foundation

public struct DashboardTopMoversSection: ReducerProtocol {
    public let app: AppProtocol
    public let pricesSceneService: PricesSceneServiceAPI

    public init(
        app: AppProtocol,
        pricesSceneService: PricesSceneServiceAPI
    ) {
        self.app = app
        self.pricesSceneService = pricesSceneService
    }

    public enum Action: Equatable {
        case onAppear
        case onFilteredDataFetched([PricesRowData])
        case onPricesDataFetched([PricesRowData])
        case onAssetTapped(PricesRowData)
    }

    public struct State: Equatable {
        public init(
            isLoading: Bool = false,
            topMovers: [PricesRowData] = []
        ) {
            self.isLoading = isLoading
            self.topMovers = topMovers
        }

        var isLoading: Bool = false
        var topMovers: [PricesRowData] = []
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                return self.pricesSceneService.pricesRowData(appMode: AppMode.trading)
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: [])
                    .eraseToEffect(Action.onPricesDataFetched)

            case .onPricesDataFetched(let topMoversData):
                return .run { run in
                    let totalNumberOfMovers = (try? await app.get(blockchain.app.configuration.dashboard.top.movers.limit, as: Int.self)) ?? 4
                    let filteredData = topMoversData
                        .filter(\.isTradable)
                        .sorted(by: { price1, price2 in
                        guard let delta1 = price1.delta?.doubleValue,
                               let delta2 = price2.delta?.doubleValue
                        else {
                            return false
                        }
                        return abs(delta1) >= abs(delta2)
                    })
                    .prefix(totalNumberOfMovers)
                    .array
                    await run.send(.onFilteredDataFetched(filteredData))
                }

            case .onFilteredDataFetched(let topMoversData):
                state.topMovers = topMoversData
            return .none

            case .onAssetTapped(let asset):
                return .fireAndForget {
                    app.post(
                        action: blockchain.ux.asset[asset.currency.code].select.then.enter.into,
                        value: blockchain.ux.asset[asset.currency.code],
                        context: [blockchain.ux.asset.select.origin: "TOP MOVERS"]
                    )
                }
            }
        }
    }
}
