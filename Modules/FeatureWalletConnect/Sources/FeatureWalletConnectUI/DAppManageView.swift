// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import FeatureWalletConnectDomain
import SwiftUI

struct DAppManageView: View {

    @BlockchainApp var app

    @StateObject private var model = Model()

    @State private var toggleSettings: Bool = false
    @State private var scrollOffset: CGPoint = .zero
    @State private var dapps: [WalletConnectPairings]?

    init() { }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.semantic.light
                .ignoresSafeArea()
            VStack {
                List {
                    ForEach(dapps ?? dappsPlaceholder, id: \.self) { dapp in
                        rowForDapp(dapp)
                            .background(Color.semantic.background)
                    }
                    .redacted(reason: dapps == nil ? .placeholder : [])
                }
                .hideScrollContentBackground()
                .disabled(toggleSettings)
                .adjustListSeparatorInset()
                .scrollOffset($scrollOffset)
                .superAppNavigationBar(
                    leading: {
                        settingsButton()
                    },
                    title: {
                        Text(L10n.Manage.title)
                            .typography(.body2)
                            .foregroundColor(.semantic.title)
                    },
                    trailing: {
                        close()
                    },
                    scrollOffset: $scrollOffset.y
                )
                VStack {
                    PrimaryButton(
                        title: L10n.Manage.buttonTitle,
                        leadingView: { Icon.scannerFilled.small().color(Color.white) },
                        action: {
                            app.post(
                                event: blockchain.ux.wallet.connect.scan.qr.entry.paragraph.button.minimal.tap,
                                context: [
                                    blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                                ]
                            )
                        }
                    )
                    .padding(.vertical, Spacing.padding2)
                    .padding(.horizontal, Spacing.padding3)
                }
                .batch {
                    set(blockchain.ux.wallet.connect.scan.qr.entry.paragraph.button.minimal.tap.then.enter.into, to: blockchain.ux.scan.QR)
                }
                .background(
                    Rectangle()
                        .fill(Color.semantic.background)
                        .cornerRadius(Spacing.padding2, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(.all, edges: .bottom)
                )
                .ignoresSafeArea(.all, edges: .bottom)
            }
            if toggleSettings {
                settingsView()
                    .zIndex(1)
            }

            if model.disconnectionFailure {
                failureAlert()
            }
        }
        .onChange(of: model.disconnectionSuccess) { newValue in
            if newValue {
                app.post(event: blockchain.ui.type.action.then.close)
            }
        }
        .onChange(of: model.disconnectionFailure, perform: { newValue in
            if newValue {
                toggleSettings = false
            }
        })
        .onAppear {
            model.prepare(app: app)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .navigationBarHidden(true)
        .bindings {
            subscribe($dapps, to: blockchain.ux.wallet.connect.active.sessions)
        }
    }

    @ViewBuilder
    func rowForDapp(_ dapp: WalletConnectPairings) -> some View {
        TableRow(
            leading: {
                if let iconUrl = dapp.iconURL {
                    AsyncMedia(
                        url: iconUrl
                    )
                    .resizingMode(.aspectFit)
                    .frame(width: 24.pt, height: 24.pt)
                } else {
                    Icon.walletConnect
                        .with(length: 24.pt)
                }
            },
            title: dapp.name.isNotEmpty ? dapp.name : L10n.Dashboard.emptyDappName,
            byline: dapp.url ?? "",
            trailing: {
                trailingRowView(dapp)
            }
        )
        .tableRowBackground(Color.clear)
        .listRowBackground(Color.semantic.background)
        .listRowSeparatorColor(Color.semantic.light)
        .tableRowHorizontalInset(0)
        .background(Color.semantic.background)
        .onTapGesture {
            app.post(
                event: blockchain.ux.wallet.connect.manage.sessions.entry.paragraph.row.tap,
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
                blockchain.ux.wallet.connect.manage.sessions.entry.paragraph.row.tap.then.enter.into,
                to: blockchain.ux.wallet.connect.session.details
            )
        }
    }

    @ViewBuilder
    func close() -> some View {
        IconButton(
            icon: .closeCirclev3.small(),
            action: { $app.post(event: blockchain.ux.wallet.connect.manage.sessions.article.plain.navigation.bar.button.close.tap) }
        )
        .batch {
            set(blockchain.ux.wallet.connect.manage.sessions.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder
    func settingsButton() -> some View {
        IconButton(
            icon: toggleSettings ? .moreVertical.small().circle() : .moreVertical.small(),
            toggle: $toggleSettings
        )
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
    func settingsView() -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        toggleSettings.toggle()
                    }
                }
            settingsPopup()
                .offset(.init(width: Spacing.padding1, height: Spacing.padding6))
                .transition(.opacity)
                .zIndex(2)
        }
    }

    @ViewBuilder
    func settingsPopup() -> some View {
        VStack(alignment: .leading) {
            Button {
                model.disconnectingInProgress = true
                $app.post(event: blockchain.ux.wallet.connect.manage.sessions.disconnect.all)
            } label: {
                Group {
                    if model.disconnectingInProgress {
                        ProgressView()
                            .progressViewStyle(
                                BlockchainCircularProgressViewStyle(
                                    stroke: .semantic.error,
                                    background: .semantic.redBG
                                )
                            )
                            .frame(width: 28.pt, height: 28.pt)
                    } else {
                        Text(L10n.Manage.disconnectAll)
                            .typography(.title3)
                            .foregroundColor(Color.semantic.destructive)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.semantic.background)
                )
                .padding(.horizontal, Spacing.padding3)
                .padding(.vertical, Spacing.padding2)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.semantic.background)
                .shadow(color: .semantic.dark.opacity(0.5), radius: 8)
        )
        .mask(RoundedRectangle(cornerRadius: 16).padding(.all, -20))
        .padding(.trailing, Spacing.padding6)
    }

    @ViewBuilder
    func failureAlert() -> some View {
        ZStack(alignment: .topLeading) {
            Color.black
                .opacity(0.2)
                .contentShape(Rectangle())
                .ignoresSafeArea()
            AlertCard(
                title: L10n.Manage.errorTitle,
                message: L10n.Manage.errorMessage,
                variant: .error,
                isBordered: true,
                onCloseTapped: {
                    withAnimation {
                        model.disconnectionFailure = false
                    }
                }
            )
            .onAppear {
                withAnimation(.default.delay(3)) {
                    model.disconnectionFailure = false
                }
            }
            .padding(.horizontal, Spacing.padding1)
            .padding(.top, Spacing.padding1)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
        }
        .zIndex(2)
    }
}

extension DAppManageView {
    class Model: ObservableObject {

        @Published var disconnectingInProgress: Bool = false
        @Published var disconnectionSuccess: Bool = false
        @Published var disconnectionFailure: Bool = false

        func prepare(app: AppProtocol) {

            app.on(blockchain.ux.wallet.connect.manage.sessions.disconnect.all.success)
                .map { _ in true }
                .receive(on: DispatchQueue.main)
                .assign(to: &$disconnectionSuccess)

            app.on(blockchain.ux.wallet.connect.manage.sessions.disconnect.all.success)
                .map { _ in false }
                .receive(on: DispatchQueue.main)
                .assign(to: &$disconnectingInProgress)

            app.on(blockchain.ux.wallet.connect.manage.sessions.disconnect.all.failure)
                .map { _ in true }
                .receive(on: DispatchQueue.main)
                .assign(to: &$disconnectionFailure)

            app.on(blockchain.ux.wallet.connect.manage.sessions.disconnect.all.failure)
                .map { _ in false }
                .receive(on: DispatchQueue.main)
                .assign(to: &$disconnectingInProgress)
        }
    }
}

extension View {
    @ViewBuilder
    func adjustListSeparatorInset() -> some View {
        if #available(iOS 16.0, *) {
            self.alignmentGuide(.listRowSeparatorLeading) { dimensions in
                dimensions[.leading]
            }
        } else {
            self
        }
    }
}

private let dappsPlaceholder: [WalletConnectPairings] = [
    .v1(DAppPairingV1(name: "some name 1", description: "some description", url: "some url", networks: [])),
    .v1(DAppPairingV1(name: "some name 2", description: "some description", url: "some url", networks: [])),
    .v2(DAppPairing(pairingTopic: "", name: "some name 3", description: "some description", url: "some url", iconUrlString: nil, networks: [], activeSession: nil)),
    .v2(DAppPairing(pairingTopic: "", name: "some name 4", description: "some description", url: "some url", iconUrlString: nil, networks: [], activeSession: nil))
]
