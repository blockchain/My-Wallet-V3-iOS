//// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureWalletConnectDomain
import SwiftUI

public struct DAppDashboardListView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @State private var dapps: [WalletConnectPairings]?

    public init() { }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                SectionHeader(
                    title: L10n.Dashboard.Header.title,
                    variant: .superapp
                )
                Spacer()
                Button {
                    app.post(
                        event: blockchain.ux.wallet.connect.manage.sessions.entry.paragraph.button.minimal.tap,
                        context: [
                            blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                        ]
                    )
                } label: {
                    Text(L10n.Dashboard.Header.seeAllLabel)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.primary)
                }
                .batch {
                    set(
                        blockchain.ux.wallet.connect.manage.sessions.entry.paragraph.button.minimal.tap.then.enter.into,
                        to: blockchain.ux.wallet.connect.manage.sessions
                    )
                }
            }
            HStack {
                VStack {
                    if dapps == nil {
                        loading()
                    }
                    if let dapps = dapps, dapps.isEmpty {
                        card()
                    }
                    if let dapps = dapps, dapps.isNotEmpty {
                        DividedVStack(spacing: 0) {
                            ForEach(dapps, id: \.self) { model in
                                rowForDapp(model)
                            }
                        }
                        .cornerRadius(16)
                    }
                }
                .background(Color.WalletSemantic.light)
            }
        }
        .padding(.horizontal, Spacing.padding2)
        .bindings {
            subscribe($dapps.animation(), to: blockchain.ux.wallet.connect.active.sessions)
        }
    }

    @ViewBuilder
    func rowForDapp(_ dapp: WalletConnectPairings) -> some View {
        TableRow(
            leading: {
                AsyncMedia(
                    url: dapp.iconURL
                )
                .resizingMode(.aspectFit)
                .frame(width: 24.pt, height: 24.pt)
            },
            title: dapp.name,
            byline: dapp.url ?? "",
            trailing: {
                trailingRowView(dapp)
            }
        )
        .tableRowBackground(Color.white)
        .onTapGesture {
            app.post(
                event: blockchain.ux.wallet.connect.session.details.entry.paragraph.row.select,
                context: [
                    blockchain.ux.wallet.connect.session.details.model: dapp,
                    blockchain.ui.type.action.then.enter.into.embed.in.navigation: false,
                    blockchain.ui.type.action.then.enter.into.grabber.visible: true,
                    blockchain.ui.type.action.then.enter.into.detents: [
                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                    ]
                ]
            )
        }
        .batch {
            set(
                blockchain.ux.wallet.connect.session.details.entry.paragraph.row.select.then.enter.into,
                to: blockchain.ux.wallet.connect.session.details
            )
        }
    }

    @ViewBuilder
    func trailingRowView(_ dapp: WalletConnectPairings) -> some View {
        if let network = dapp.networks.first, dapp.networks.count == 1 {
            singleNetworkView(network)
        } else {
            ZStack(alignment: .trailing) {
                ForEach(0..<dapp.networks.count, id: \.self) { i in
                    if let url = dapp.networks[i].nativeAsset.logoURL {
                        ZStack {
                            AsyncMedia(url: url)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 18, height: 18)
                            Circle()
                                .strokeBorder(.white, lineWidth: 2)
                                .frame(width: 18, height: 18)
                        }
                        .offset(x: -(Double(i) * 14))
                    }
                }
            }
        }
    }

    @ViewBuilder
    func singleNetworkView(_ network: EVMNetwork) -> some View {
        HStack(spacing: Spacing.padding1) {
            AsyncMedia(url: network.nativeAsset.logoURL)
                .aspectRatio(contentMode: .fill)
                .frame(width: 18, height: 18)

            Text(network.networkConfig.name)
                .typography(.caption1)
                .foregroundColor(.semantic.title)
        }
        .padding(.horizontal, Spacing.padding1)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(Color.semantic.light)
        )
    }

    @ViewBuilder
    func loading() -> some View {
        AlertCard(
            title: L10n.Dashboard.Empty.title,
            message: L10n.Dashboard.Empty.subtitle
        )
        .disabled(true)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder
    func card() -> some View {
        TableRow(
            leading: {
                Icon.repeat
                    .circle(backgroundColor: .semantic.primary)
                    .with(length: 32.pt)
                    .iconColor(.white)
            },
            title: L10n.Dashboard.Empty.title,
            byline: L10n.Dashboard.Empty.subtitle,
            trailing: {
                SmallSecondaryButton(
                    icon: Icon.viewfinder.micro().color(.semantic.light)
                ) {
                    app.post(
                        event: blockchain.ux.scan.QR.entry.paragraph.button.minimal.tap,
                        context: [
                            blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                        ]
                    )
                }
            }
        )
        .batch {
            set(blockchain.ux.scan.QR.entry.paragraph.button.minimal.tap.then.enter.into, to: blockchain.ux.scan.QR)
        }
        .tableRowBackground(Color.white)
        .cornerRadius(16)
    }
}
