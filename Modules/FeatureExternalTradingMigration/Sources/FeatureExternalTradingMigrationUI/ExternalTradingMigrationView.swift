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
        Group {
            content
                .sheet(
                    isPresented: viewStore.$migrationInProgressPresented,
                    content: {
                        BakktMigrationInProgressView(onDone: {
                            viewStore.send(.onFlowComplete)
                        })
                    }
                )
                .sheet(item: viewStore.$upgradeError) { error in
                    ErrorView(ux: error)
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
            onDone: {
                viewStore.send(.onUpgrade)
            },
            isLoading: viewStore.isSubmittingMigration
        )
    }

    @ViewBuilder var existingUserAssetsNoConsolidationView: some View {
        BakktConsentView(
            hasAssetsToConsolidate: false,
            onDone: {
                viewStore.send(.onUpgrade)
            },
            onContinue: nil,
            isLoading: viewStore.isSubmittingMigration
        )
    }

    @ViewBuilder var existingUserAssetsToConsolidateView: some View {
        VStack {
            BakktConsentView(
                hasAssetsToConsolidate: true,
                onDone: nil,
                onContinue: {
                    viewStore.send(.onContinue)
                },
                isLoading: viewStore.isSubmittingMigration
            )

            assetMigrationInfoNavigationLink
        }
    }

    @ViewBuilder var assetMigrationInfoNavigationLink: some View {
        if let migrationInfo = viewStore.migrationInfo,
           let consolidationBalances = migrationInfo.consolidatedBalances {
            NavigationLink(
                destination: BakktAssetMigrationView(
                    beforeMigrationBalances: consolidationBalances.beforeMigration ,
                    afterMigrationBalance: consolidationBalances.afterMigration,
                    onDone: {
                        viewStore.send(.onUpgrade)
                    },
                    onGoBack: {
                        viewStore.send(.setNavigation(isActive: false))
                    },
                    isLoading: viewStore.isSubmittingMigration
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
            store: Store(
                initialState: .init(flow: .existingUserAssetsNoConsolidationNeeded),
                reducer: {
                    ExternalTradingMigration(app: App.preview, externalTradingMigrationService: ExternalTradingMigrationServiceMock())
                }
            )
        )

        ExternalTradingMigrationView(
            store: Store(
                initialState: .init(flow: .existingUsersNoAssets),
                reducer: {
                    ExternalTradingMigration(app: App.preview, externalTradingMigrationService: ExternalTradingMigrationServiceMock())
                }
            )
        )

        ExternalTradingMigrationView(
            store: Store(
                initialState: .init(flow: .existingUserAssetsConsolidationNeeded),
                reducer: {
                    ExternalTradingMigration(app: App.preview, externalTradingMigrationService: ExternalTradingMigrationServiceMock())
                }
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
