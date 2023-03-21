// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import SwiftUI

@available(iOS 15, *)
public struct DexDashboardView: View {

    @BlockchainApp var app
    let balances: () -> AnyPublisher<DelegatedCustodyBalances, Error>
    @State var showIntro: Bool = false

    public init(
        balances: @escaping () -> AnyPublisher<DelegatedCustodyBalances, Error>
    ) {
        self.balances = balances
    }

    public var body: some View {
            VStack {
                bodyContent
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                scrollOffset: nil
            )
            .onAppear {
                showIntro = shouldShowIntro(app: app)
            }
            .sheet(isPresented: $showIntro, content: {
                DexIntroView(
                    store: Store(
                        initialState: DexIntro.State(),
                        reducer: DexIntro(
                            app: app,
                            onDismiss: {
                                showIntro = false
                            }
                        )
                    )
                )
            })
    }

    @ViewBuilder private var bodyContent: some View {
        DexMainView(
            store: Store(
                initialState: DexMain.State(
                    source: .init(
                        amount: nil,
                        amountFiat: nil,
                        balance: nil,
                        fees: nil
                    ),
                    destination: nil,
                    fiatCurrency: .USD
                ),
                reducer: DexMain(
                    balances: balances
                )
            )
        )
    }
}

private func shouldShowIntro(app: AppProtocol) -> Bool {
    !introDidShow(app: app)
}

private func introDidShow(app: AppProtocol) -> Bool {
    (try? app.state.get(blockchain.ux.currency.exchange.dex.intro.did.show)) ?? false
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
    .batch(
        .set(blockchain.ux.user.account.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.user.account)
    )
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
    .batch(
        .set(blockchain.ux.scan.QR.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.scan.QR)
    )
    .id(blockchain.ux.scan.QR.entry.description)
    .accessibility(identifier: blockchain.ux.scan.QR.entry.description)
}

struct DexDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15, *) {
            DexDashboardView(balances: { .just(.preview) })
                .app(App.preview)
        } else {
            EmptyView()
        }
    }
}
