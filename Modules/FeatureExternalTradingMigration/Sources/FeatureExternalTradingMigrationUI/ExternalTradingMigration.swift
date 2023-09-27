import Blockchain
import Combine
import ComposableArchitecture
import Errors
import FeatureExternalTradingMigrationDomain
import Foundation

public struct ExternalTradingMigration: ReducerProtocol {
    public enum Flow {
        case existingUsersNoAssets
        case existingUserAssetsNoConsolidationNeeded
        case existingUserAssetsConsolidationNeeded
    }

    // MARK: - Types

    public struct State: Equatable {
        public init(flow: Flow? = nil) {
            self.flow = flow
        }

        var flow: Flow?
        var migrationInfo: ExternalTradingMigrationInfo?
        var showConsolidatedAssets: Bool = false
    }

    public enum Action: Equatable {
        case initialize
        case fetchMigrationState(ExternalTradingMigrationInfo)
        case setNavigation(isActive: Bool)
        case onContinue
        case onDone
    }

    // MARK: - Properties

    private let app: AppProtocol

    // MARK: - Setup

    public init (
        app: AppProtocol
    ) {
        self.app = app
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .initialize:
            return .run { send in
                if let migrationInfo = try? await app.get(
                    blockchain.api.nabu.gateway.user.external.brokerage.migration,
                    as: ExternalTradingMigrationInfo.self
                ) {
                    await send(.fetchMigrationState(migrationInfo))
                }
            }
        case .fetchMigrationState(let migrationInfo):
            state.migrationInfo = migrationInfo
            
            if migrationInfo.consolidatedBalances.beforeMigration.isNotEmpty {
                state.flow = .existingUserAssetsConsolidationNeeded
                return .none
            }

            if migrationInfo.availableBalances.isNotEmpty {
                state.flow = .existingUserAssetsNoConsolidationNeeded
                return .none
            }

            state.flow = .existingUsersNoAssets
            return .none
            
        case .setNavigation(let isActive):
            state.showConsolidatedAssets = isActive
            return .none
        case .onContinue:
            state.showConsolidatedAssets.toggle()
            return .none
        case .onDone:
            return .none
        }
    }
}
