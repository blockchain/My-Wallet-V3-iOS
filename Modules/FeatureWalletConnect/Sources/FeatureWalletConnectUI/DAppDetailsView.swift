// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import FeatureWalletConnectDomain
import SwiftUI

struct DAppDetailsView: View {

    @BlockchainApp var app

    @State private var width: CGFloat = 0

    private var details: WalletConnectPairings

    @StateObject private var model = Model()

    init(details: WalletConnectPairings) {
        self.details = details
    }

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            HStack(alignment: .top) {
                Spacer()
                IconButton(icon: .closeCirclev2.small()) {
                    $app.post(event: blockchain.ux.wallet.connect.session.details.entry.paragraph.button.icon.tap)
                }
                .batch {
                    set(blockchain.ux.wallet.connect.session.details.entry.paragraph.button.icon.tap.then.close, to: true)
                }
            }
            VStack(spacing: Spacing.padding1) {
                if let imageURL = details.iconURL {
                    AsyncMedia(url: imageURL)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .cornerRadius(13)
                } else {
                    Icon.walletConnect
                        .with(length: 64.pt)
                }
                Text(details.name.isNotEmpty ? details.name : L10n.Dashboard.emptyDappName)
                    .typography(.title3)
                    .foregroundColor(.semantic.text)
                    .multilineTextAlignment(.center)
                    .frame(width: width)
                    .padding(.bottom, Spacing.padding1)
                Text(details.description)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
                    .multilineTextAlignment(.center)
                    .frame(width: width)
            }
            .padding(.bottom, Spacing.padding2)
            HStack {
                if model.disconnectionFailed {
                    AlertToast(text: L10n.Details.disconnectFailure, variant: .error)
                        .transition(.opacity)
                        .onAppear {
                            withAnimation(.default.delay(2)) {
                                model.disconnectionFailed = false
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                model.disconnectionFailed = false
                            }
                        }
                } else {
                    DestructivePrimaryButton(title: L10n.List.disconnect, isLoading: model.isLoading) {
                        model.isLoading = true
                        $app.post(
                            event: blockchain.ux.wallet.connect.session.details.disconnect,
                            context: [
                                blockchain.ux.wallet.connect.session.details.model: details,
                                blockchain.ux.wallet.connect.session.details.name: details.name
                            ]
                        )
                    }
                    .transition(.opacity)
                    .onChange(of: model.disconnectionSuccess) { newValue in
                        if newValue {
                            app.post(event: blockchain.ui.type.action.then.close)
                        }
                    }
                }
            }
        }
        .background(
            GeometryReader { proxy -> Color in
                let rect = proxy.frame(in: .global)
                DispatchQueue.main.async {
                    width = rect.width
                }
                return Color.clear
            }
        )
        .padding(Spacing.padding2)
        .onAppear {
            model.prepare(app: app)
        }
    }
}

extension DAppDetailsView {
    class Model: ObservableObject {

        @Published var isLoading: Bool = false
        @Published var disconnectionSuccess: Bool = false
        @Published var disconnectionFailed: Bool = false

        init() {}

        func prepare(app: AppProtocol) {

            app.on(blockchain.ux.wallet.connect.session.details.disconnect.success)
                .map { _ in false }
                .receive(on: DispatchQueue.main)
                .assign(to: &$isLoading)

            app.on(blockchain.ux.wallet.connect.session.details.disconnect.success)
                .map { _ in true }
                .receive(on: DispatchQueue.main)
                .assign(to: &$disconnectionSuccess)

            app.on(blockchain.ux.wallet.connect.session.details.disconnect.failure)
                .map { _ in false }
                .receive(on: DispatchQueue.main)
                .assign(to: &$isLoading)

            app.on(blockchain.ux.wallet.connect.session.details.disconnect.failure)
                .map { _ in true }
                .receive(on: DispatchQueue.main)
                .assign(to: &$disconnectionSuccess)
        }
    }
}
