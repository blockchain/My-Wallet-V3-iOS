// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import MoneyKit
import SwiftUI

@available(iOS 15, *)
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
            .sheet(isPresented: viewStore.introSheetBinding, content: {
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

@available(iOS 15, *)
extension ViewStore where ViewState == DexDashboard.State, ViewAction == DexDashboard.Action {
    var introSheetBinding: Binding<Bool> {
        binding(get: { $0.showIntro }, send: DexDashboard.Action.onAppear)
    }
}

// MARK: Common Nav Bar Items

@ViewBuilder
func dashboardLeadingItem(app: AppProtocol) -> some View {
    IconButton(icon: .userv2.color(.black).small()) {
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
    IconButton(icon: .viewfinder.color(.black).small()) {
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

@available(iOS 15, *)
struct DexDashboardView_Previews: PreviewProvider {

    static var app: AppProtocol = {
        let app = App.preview
        app.state.set(
            blockchain.ux.currency.exchange.dex.intro.did.show,
            to: false
        )
        app.state.set(
            blockchain.user.currency.preferred.fiat.trading.currency,
            to: FiatCurrency.USD
        )
        return app
    }()

    static var previews: some View {
        DexDashboardView(
            store: Store(
                initialState: .init(),
                reducer: DexDashboard(
                    app: app,
                    balances: { .just(.preview) }
                )
            )
        )
        .app(app)
    }
}
