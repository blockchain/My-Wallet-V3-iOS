// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import FeatureWalletConnectDomain
import Foundation
import SwiftUI

struct EventDetails: Equatable {
    let name: String
    let image: String?
    let url: String
    let description: String
    let account: String
    let chains: [EVMNetwork]
}

public struct WalletConnectEventViewV2: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    private let state: EventConnectionState

    @StateObject var model: Model

    init(state: EventConnectionState) {
        self.state = state
        _model = StateObject(
            wrappedValue: Model(
                state: state
            )
        )
    }

    public var body: some View {
        VStack {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    Spacer()
                    IconButton(icon: .closeCirclev2.small()) {
                        $app.post(event: blockchain.ux.wallet.connect.pair.request.entry.paragraph.button.icon.tap)
                    }
                    .batch {
                        set(blockchain.ux.wallet.connect.pair.request.entry.paragraph.button.icon.tap.then.close, to: true)
                    }
                }
                if let imageURL = model.details?.image, let imageResource = URL(string: imageURL) {
                    ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                        AsyncMedia(url: imageResource)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .cornerRadius(13)
                        ProgressView()
                            .opacity(model.isLoading ? 1.0 : 0.0)
                            .redacted(reason: [])
                        if let decorationImage = state.decorationImage {
                            Image(uiImage: decorationImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .offset(x: 15, y: 15)
                        }
                    }
                }
                Text(model.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(model.description)
                    .typography(.paragraph1)
                    .foregroundColor(.textSubheading)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 32)
                if state == .request {
                    information
                    buttons
                }
            }
            .redacted(reason: model.isLoading ? .placeholder : [])
            .padding(24)
            .onAppear {
                model.prepare(app: app, context: context)
            }
        }
    }

    @ViewBuilder
    private var information: some View {
        HStack(spacing: Spacing.padding1) {
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(L10n.Connection.wallet)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
                Text(model.details?.account ?? "")
                    .frame(maxWidth: 90.pt)
                    .typography(.body1)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundColor(.semantic.body)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: Spacing.textSpacing) {
                Text(L10n.Connection.networks)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
                ZStack(alignment: .trailing) {
                    if let networks = model.details?.chains {
                        ForEach(0..<networks.count, id: \.self) { i in
                            if let url = networks[i].nativeAsset.logoURL {
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
        }
    }

    private var buttons: some View {
        HStack(spacing: Spacing.padding1) {
            if let secondaryButtonTitle = state.secondaryButtonTitle,
               let secondaryAction = state.secondaryButtonAction
            {
                MinimalButton(
                    title: secondaryButtonTitle
                ) {
                    $app.post(event: secondaryAction.paragraph.button.minimal.tap)
                }
                .batch {
                    set(secondaryAction.paragraph.button.minimal.tap.then.emit, to: secondaryAction)
                }
            }
            if let primaryButtonTitle = state.mainButtonTitle,
               let primaryAction = state.mainButtonAction
            {
                PrimaryButton(title: primaryButtonTitle) {
                    $app.post(event: primaryAction.paragraph.button.primary.tap)
                }
                .batch {
                    set(primaryAction.paragraph.button.primary.tap.then.emit, to: primaryAction)
                }
            }
        }
    }
}

extension WalletConnectEventViewV2 {
    class Model: ObservableObject {
        @Published var details: EventDetails?

        var isLoading: Bool {
            details == nil
        }

        var title: String {
            guard let details else {
                // used while fetching the proposal
                return String(format: L10n.Connection.dAppWantsToConnect, "loading....")
            }
            switch state {
            case .request:
                return String(format: L10n.Connection.dAppWantsToConnect, details.name)
            case .success:
                return String(format: L10n.Connection.dAppConnectionSuccess, details.name)
            }
        }

        var description: String {
            guard let details else {
                return "loading...."
            }
            switch state {
            case .request:
                return details.url
            case .success:
                return ""
            }
        }

        private let state: EventConnectionState

        init(state: EventConnectionState) {
            self.state = state
        }

        func prepare(app: AppProtocol, context: Tag.Context) {
            app.publisher(for: blockchain.ux.wallet.connect.pair.request.proposal, as: WalletConnectProposal.self)
                .compactMap(\.value)
                .map(EventDetails.init(from:))
                .assign(to: &$details)
        }
    }
}

extension EventDetails {
    init(from proposal: WalletConnectProposal) {
        self = .init(
            name: proposal.proposal.proposer.name,
            image: proposal.proposal.proposer.icons.first,
            url: proposal.proposal.proposer.url,
            description: proposal.proposal.proposer.description,
            account: proposal.account,
            chains: proposal.networks
        )
    }
}
