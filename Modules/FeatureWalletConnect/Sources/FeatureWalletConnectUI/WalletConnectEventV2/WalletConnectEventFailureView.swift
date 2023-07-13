// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import FeatureWalletConnectDomain
import Foundation
import SwiftUI
import Web3Wallet

struct EventFailureDetails: Equatable {
    let name: String
    let image: String?
    let url: String
    let description: String
}

public struct WalletConnectEventFailureView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @StateObject var model = Model()

    init() {}

    public var body: some View {
        VStack {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    Spacer()
                    IconButton(icon: .closeCirclev2.small()) {
                        $app.post(event: blockchain.ux.wallet.connect.failure.entry.paragraph.button.icon.tap)
                    }
                    .batch {
                        set(blockchain.ux.wallet.connect.failure.entry.paragraph.button.icon.tap.then.close, to: true)
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
                        if let decorationImage = model.decorationImage {
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
                PrimaryButton(title: L10n.ok) {
                    $app.post(event: blockchain.ux.wallet.connect.failure.entry.paragraph.button.primary.tap)
                }
                .batch {
                    set(blockchain.ux.wallet.connect.failure.entry.paragraph.button.primary.tap.then.close, to: true)
                }
            }
            .redacted(reason: model.isLoading ? .placeholder : [])
            .padding(24)
            .onAppear {
                model.prepare(app: app, context: context)
            }
        }
    }
}

extension WalletConnectEventFailureView {
    class Model: ObservableObject {
        @Published var details: EventFailureDetails?

        var isLoading: Bool {
            details == nil
        }

        var title: String {
            guard let details else {
                // used while fetching the proposal
                return String(format: L10n.Connection.dAppConnectionFailure, "dApp Name")
            }
            guard details.name.isNotEmpty else {
                return L10n.Connection.emptyNameDappConnectFailure
            }
            return String(format: L10n.Connection.dAppConnectionFailure, details.name)
        }

        var description: String {
            guard let details else {
                return "loading...."
            }
            return details.description
        }

        var decorationImage: UIImage? {
            UIImage(
                named: "fail-decorator",
                in: .featureWalletConnectUI,
                with: nil
            )
        }

        func prepare(app: AppProtocol, context: Tag.Context) {
            let message = (try? context[blockchain.ux.wallet.connect.failure.message].decode(String.self)) ?? L10n.Connection.dAppConnectionFail
            let metadata = try? context[blockchain.ux.wallet.connect.failure.metadata].decode(AppMetadata.self)

            details = EventFailureDetails(
                name: metadata?.name ?? "",
                image: metadata?.icons.first,
                url: metadata?.url ?? "",
                description: message
            )
        }
    }
}
