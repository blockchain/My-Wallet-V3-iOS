// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureTopMoversCryptoDomain
import Foundation
import MoneyKit

public enum TopMoversPresenter {
    case dashboard, prices, accountPicker

    var action: L & I_blockchain_ui_type_task {
        switch self {
        case .dashboard:
            return blockchain.ux.dashboard.top.movers.select
        case .prices:
            return blockchain.ux.prices.top.movers.select
        case .accountPicker:
            return blockchain.ux.transaction.select.target.top.movers
        }
    }
}

public struct TopMoversSection: ReducerProtocol {
    public let app: AppProtocol
    public let topMoversService: TopMoversServiceAPI

    public init(
        app: AppProtocol,
        topMoversService: TopMoversServiceAPI
    ) {
        self.app = app
        self.topMoversService = topMoversService
    }

    public enum Action: Equatable {
        case onAppear
        case onFilteredDataFetched([TopMoverInfo])
        case onPricesDataFetched([TopMoverInfo])
        case onFastRisingCalculated(Bool)
    }

    public struct State: Equatable {
        var presenter: TopMoversPresenter
        var isLoading: Bool
        var topMovers: [TopMoverInfo] = []
        var fastRising: Bool?

        public init(
            presenter: TopMoversPresenter,
            isLoading: Bool = false,
            topMovers: [TopMoverInfo] = []
        ) {
            self.isLoading = isLoading
            self.topMovers = topMovers
            self.presenter = presenter
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        for await appMode in app.stream(blockchain.app.mode, as: AppMode.self) {
                            print("🎾 fetching top movers for \(appMode)")
                            guard let appMode = appMode.value else {
                                return
                            }
                            for try await topMovers in topMoversService.alternativeTopMovers(for: appMode, with: .EUR) {
                                await send(.onPricesDataFetched(topMovers))
                            }
                        }

                    } catch {}
                }

            case .onPricesDataFetched(let topMoversData):
                return .run { send in
                    let totalNumberOfMovers = await (try? app.get(blockchain.app.configuration.dashboard.top.movers.limit, as: Int.self)) ?? 4
                    let fastRisingMinDelta = await (try? app.get(blockchain.app.configuration.prices.rising.fast.percent, as: Double.self)) ?? 4

                    let filteredData = topMoversData
                    .prefix(totalNumberOfMovers)
                    .array

                    let hasFastRisingItem = filteredData.filter { Decimal(fastRisingMinDelta / 100).isLessThanOrEqualTo($0.delta ?? 0) }.isNotEmpty
                    await send(.onFastRisingCalculated(hasFastRisingItem))
                    await send(.onFilteredDataFetched(topMoversData))
                }

            case .onFastRisingCalculated(let isFastRising):
                state.fastRising = isFastRising
                return .none

            case .onFilteredDataFetched(let topMoversData):
                state.topMovers = topMoversData

            return .none
            }
        }
    }
}
