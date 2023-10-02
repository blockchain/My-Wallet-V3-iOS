import Blockchain
import Combine
import ComposableArchitecture
import DIKit
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
        @BindingState var migrationInProgressPresented: Bool = false
        public init(flow: Flow? = nil) {
            self.flow = flow
        }

        var flow: Flow?
        var migrationInfo: ExternalTradingMigrationInfo?
        var showConsolidatedAssets: Bool = false
    }

    public enum Action: Equatable, BindableAction {
        case initialize
        case fetchMigrationState(ExternalTradingMigrationInfo)
        case setNavigation(isActive: Bool)
        case onContinue
        case onUpgrade
        case binding(BindingAction<State>)
        case migrationInProgressModalDismissed(Bool)
        case onFlowComplete
    }

    // MARK: - Properties

    private let app: AppProtocol
    private let externalTradingMigrationService: ExternalTradingMigrationServiceAPI

    // MARK: - Setup

    public init (
        app: AppProtocol,
        externalTradingMigrationService: ExternalTradingMigrationServiceAPI
    ) {
        self.app = app
        self.externalTradingMigrationService = externalTradingMigrationService
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .initialize:
                return .run { send in
                    if let migrationInfo = try? await externalTradingMigrationService
                        .fetchMigrationInfo() {
                        await send(.fetchMigrationState(migrationInfo))
                    }
                }
            case .fetchMigrationState(let migrationInfo):
                state.migrationInfo = migrationInfo

                if migrationInfo.consolidatedBalances.beforeMigration.isNotEmpty {
                    state.flow = .existingUserAssetsConsolidationNeeded
                    return .none
                }

                if migrationInfo.availableBalances?.isNotEmpty == true {
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

            case .onFlowComplete:
                state.migrationInProgressPresented = false
                app.post(event: blockchain.user.event.did.update)
                app.post(event: blockchain.ux.dashboard.external.trading.migration.article.plain.navigation.bar.button.close.tap)
                return .none

            case .onUpgrade:
                state.migrationInProgressPresented = true
                return .run { [externalTradingMigrationService] _ in
                    do {
                        try await externalTradingMigrationService.startMigration()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .migrationInProgressModalDismissed(let dismissed):
                state.migrationInProgressPresented = dismissed
                return .none

            case .binding:
                return .none
            }
        }
    }
}
