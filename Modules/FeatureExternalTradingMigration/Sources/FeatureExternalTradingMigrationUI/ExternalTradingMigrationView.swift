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
            Group {
                content
                    .sheet(isPresented: viewStore.$migrationInProgressPresented,
                           content: {
                        BakktMigrationInProgressView(onDone: {
                            viewStore.send(.onFlowComplete)
                        })
                    })
            }
        }
    }

    @ViewBuilder
    var content: some View {
        switch viewStore.flow {
        case .existingUsersNoAssets:
            existingUserNoAssetsFlowView
        case .existingUserAssetsConsolidationNeeded:
            existingUserAssetsToConsolidateView
        case .existingUserAssetsNoConsolidationNeeded:
            existingUserAssetsNoConsolidationView
        case .none:
            ProgressView()
                .onAppear {
                    viewStore.send(.initialize)
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
                viewStore.send(.onUpgrade)
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

            assetMigrationInfoNavigationLink
        }
    }

    @ViewBuilder var assetMigrationInfoNavigationLink: some View {
        if let migrationInfo = viewStore.migrationInfo {
            NavigationLink(
                destination: BakktAssetMigrationView(
                    beforeMigrationBalances: migrationInfo.consolidatedBalances.beforeMigration,
                    afterMigrationBalance: migrationInfo.consolidatedBalances.afterMigration,
                    onDone: {
                    viewStore.send(.onUpgrade)
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

struct ExternalTradingMigrationView_Preview: PreviewProvider {
    static var previews: some View {
        ExternalTradingMigrationView(
            store: .init(
                initialState: .init(flow: .existingUserAssetsNoConsolidationNeeded),
                reducer: ExternalTradingMigration(app: App.preview, externalTradingMigrationService: ExternalTradingMigrationServiceMock())
            )
        )
        
        
        ExternalTradingMigrationView(
            store: .init(
                initialState: .init(flow: .existingUsersNoAssets),
                reducer: ExternalTradingMigration(app: App.preview, externalTradingMigrationService: ExternalTradingMigrationServiceMock())
            )
        )
        
        ExternalTradingMigrationView(
            store: .init(
                initialState: .init(flow: .existingUserAssetsConsolidationNeeded),
                reducer: ExternalTradingMigration(app: App.preview, externalTradingMigrationService: ExternalTradingMigrationServiceMock())
            )
        )
    }
}

private class ExternalTradingMigrationServiceMock: ExternalTradingMigrationServiceAPI {
    func startMigration() async throws {}
    
    func fetchMigrationInfo() async throws -> FeatureExternalTradingMigrationDomain.ExternalTradingMigrationInfo? {
        nil
    }
}
