// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureDashboardDomain
import Foundation
import MoneyKit
import ToolKit

struct TotalBalanceInfo: Equatable {
    let total: MoneyValue
}

struct TotalBalanceService {
    var totalBalance: @Sendable () async throws -> TotalBalanceInfo
}

extension TotalBalanceService: DependencyKey {
    static var liveValue: TotalBalanceService {
        let tradingBalanceService = TradingTotalBalanceService(app: DIKit.resolve(), repository: DIKit.resolve())
        let defiBalanceService = DeFiTotalBalanceService(app: DIKit.resolve(), repository: DIKit.resolve())
        let app: AppProtocol = DIKit.resolve()
        let live = TotalBalanceService.Live(
            tradingBalanceService: tradingBalanceService,
            defiBalanceService: defiBalanceService,
            app: app
        )
        return TotalBalanceService(
            totalBalance: {
                try await live.totalBalance()
            }
        )
    }
    static var testValue = TotalBalanceService(totalBalance: { unimplemented() })
    static var previewValue = TotalBalanceService(totalBalance: { .init(total: .one(currency: .USD)) })
}

extension DependencyValues {
    var totalBalanceService: TotalBalanceService {
        get { self[TotalBalanceService.self] }
        set { self[TotalBalanceService.self] = newValue }
    }
}

// MARK: - Private

extension TotalBalanceService {
    struct Live {
        let tradingBalanceService: TradingTotalBalanceService
        let defiBalanceService: DeFiTotalBalanceService
        let app: AppProtocol

        init(
            tradingBalanceService: TradingTotalBalanceService,
            defiBalanceService: DeFiTotalBalanceService,
            app: AppProtocol
        ) {
            self.tradingBalanceService = tradingBalanceService
            self.defiBalanceService = defiBalanceService
            self.app = app
        }

        func totalBalance() async throws -> TotalBalanceInfo {
            let tradingInfo = try await tradingBalanceService.fetchTotalBalance().await()
            let defiInfo = try await defiBalanceService.fetchTotalBalance().await()
            if let tradingInfo = tradingInfo.success {
                app.state.set(blockchain.ux.dashboard.total.trading.balance.info, to: tradingInfo)
            }

            if let defiInfo = defiInfo.success {
                app.state.set(blockchain.ux.dashboard.total.defi.balance, to: defiInfo)
            }

            guard let tradingInfo = tradingInfo.success else {
                throw BalanceInfoError.unableToRetrieve
            }
            guard let defiInfo = defiInfo.success else {
                throw BalanceInfoError.unableToRetrieve
            }
            let total = try tradingInfo.balance + defiInfo.balance
            app.state.set(blockchain.ux.dashboard.total.balance, to: total)
            return TotalBalanceInfo(
                total: total
            )
        }
    }
}
