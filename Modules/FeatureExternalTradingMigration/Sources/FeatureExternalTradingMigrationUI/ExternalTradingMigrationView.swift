import Blockchain
import BlockchainUI
import ComposableArchitecture
import FeatureExternalTradingMigrationDomain
import Localization
import SwiftUI

@MainActor
public struct ExternalTradingMigrationView: View {
    let store: StoreOf<ExternalTradingMigration>
    @ObservedObject var viewStore: ViewStoreOf<ExternalTradingMigration>
    public init(store: StoreOf<ExternalTradingMigration>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: { $0 })
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
                switch viewStore.flow {
                case .existingUsersNoAssets:
                    existingUserNoAssetsFlowView
                case .existingUserAssetsConsolidationNeeded:
                    existingUserAssetsToConsolidateView
                case .existingUserAssetsNoConsolidationNeeded:
                    existingUserAssetsNoConsolidationView
                case .none:
                    ProgressView()
                        .onAppear{
                            viewStore.send(.initialize)
                        }
                }
        }
    }

    @ViewBuilder var existingUserNoAssetsFlowView: some View {
        BakktTermsAndConditionsView(
            onDone: {}
        )
    }

    @ViewBuilder var existingUserAssetsNoConsolidationView: some View {
        BakktConsentView(
            hasAssetsToConsolidate: false,
            onDone: {
                viewStore.send(.onDone)
            },
            onContinue: nil
        )
    }

    @ViewBuilder var existingUserAssetsToConsolidateView: some View {
        VStack {
            BakktConsentView(
                hasAssetsToConsolidate: true,
                onDone: nil,
                onContinue: {
                    viewStore.send(.onContinue)
                }
            )

            contentView
        }
    }

    @ViewBuilder var contentView: some View {
        if let migrationInfo = viewStore.migrationInfo {
            NavigationLink(
                destination: BakktAssetMigrationView(
                    beforeMigrationBalances: migrationInfo.consolidatedBalances.beforeMigration,
                    afterMigrationBalance: migrationInfo.consolidatedBalances.afterMigration,
                    onDone: {
                    viewStore.send(.onDone)
                    }, 
                    onGoBack: {
                        viewStore.send(.setNavigation(isActive: false))
                    }
                ),
                isActive: viewStore.binding(
                    get: \.showConsolidatedAssets,
                    send: ExternalTradingMigration.Action.setNavigation(isActive:)
                ),
                label: {}
            )
        }
    }
}

//#Preview {
//    ExternalTradingMigrationView(
//        store: .init(
//            initialState: .init(flow: .existingUserAssetsNoConsolidationNeeded),
//            reducer: ExternalTradingMigration(app: App.preview)
//        )
//    )
//}

//#Preview {
//    ExternalTradingMigrationView(
//        store: .init(
//            initialState: .init(flow: .existingUsersNoAssets),
//            reducer: ExternalTradingMigration(app: App.preview)
//        )
//    )
//}

//#Preview {
//    ExternalTradingMigrationView(
//        store: .init(
//            initialState: .init(flow: .existingUserAssetsConsolidationNeeded),
//            reducer: ExternalTradingMigration(app: App.preview)
//        )
//    )
//}
