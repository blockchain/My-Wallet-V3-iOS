// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import DelegatedSelfCustodyDomain
import SwiftUI

public struct DexDashboardView: View {

    let store: Store<DexDashboard.State, DexDashboard.Action>
    @BlockchainApp var app

    public init(store: Store<DexDashboard.State, DexDashboard.Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                DexMainView(
                    store: store.scope(state: \.main, action: DexDashboard.Action.mainAction)
                )
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                scrollOffset: nil
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(isPresented: viewStore.binding(\.$showIntro), content: {
                DexIntroView(
                    store: store.scope(
                        state: \.intro,
                        action: DexDashboard.Action.introAction
                    )
                )
            })
        }
    }
}

// MARK: Common Nav Bar Items

@ViewBuilder
func dashboardLeadingItem(app: AppProtocol) -> some View {
    IconButton(icon: .userv2.color(.semantic.title).small()) {
        app.post(
            event: blockchain.ux.user.account.entry.paragraph.button.icon.tap,
            context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
        )
    }
    .batch {
        set(blockchain.ux.user.account.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.user.account)
    }
    .id(blockchain.ux.user.account.entry.description)
    .accessibility(identifier: blockchain.ux.user.account.entry.description)
}

@ViewBuilder
func dashboardTrailingItem(app: AppProtocol) -> some View {
    IconButton(icon: .viewfinder.color(.semantic.title).small()) {
        app.post(
            event: blockchain.ux.scan.QR.entry.paragraph.button.icon.tap,
            context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
        )
    }
    .batch {
        set(blockchain.ux.scan.QR.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.scan.QR)
    }
    .id(blockchain.ux.scan.QR.entry.description)
    .accessibility(identifier: blockchain.ux.scan.QR.entry.description)
}

struct DexDashboardView_Previews: PreviewProvider {

    private static var app = App.preview
        .withPreviewData()
        .setup { app in
            app.state.set(
                blockchain.ux.currency.exchange.dex.intro.did.show,
                to: false
            )
        }

    static var previews: some View {
        DexDashboardView(
            store: Store(
                initialState: .init(),
                reducer: DexDashboard(
                    app: app,
                    analyticsRecorder: MockAnalyticsRecorder()
                )
            )
        )
        .app(app)
    }
}

final class MockAnalyticsRecorder: AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvent) {}
}
