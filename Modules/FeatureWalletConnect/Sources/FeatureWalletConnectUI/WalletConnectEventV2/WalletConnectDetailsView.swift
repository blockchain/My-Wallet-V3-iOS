// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import FeatureWalletConnectDomain
import Foundation
import SwiftUI

struct SessionDetails: Equatable {
//    struct Account: Equatable {
//        let name: CryptoCurrency
//        let address: String
//    }
    let name: String
    let image: String
    let description: String
//    let account: Account
//    let chains: [EVMNetwork]
}

public struct WalletConnectDetailsView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @StateObject var model = Model()

    public init() { }

    public var body: some View {
        VStack {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    IconButton(icon: .closeCirclev2.small()) {
                        $app.post(event: blockchain.ux.wallet.connect.session.details.entry.paragraph.button.icon.tap)
                    }
                    .batch {
                        set(blockchain.ux.wallet.connect.pair.request.entry.paragraph.button.icon.tap.then.close, to: true)
                    }
                }
                if let imageURL = model.details?.image, let imageResource = URL(string: imageURL) {
                    ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                        AsyncMedia(url: imageResource)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .cornerRadius(13)
                    }
                }
                Text(model.details?.name ?? "")
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(model.details?.description ?? "")
                    .typography(.paragraph1)
                    .foregroundColor(.textSubheading)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 32)
                HStack {
                    PrimaryButton(title: L10n.List.disconnect) {
                        $app.post(event: blockchain.ux.wallet.connect.session.details.disconnect.paragraph.button.primary.tap)
                    }
                    .batch {
                        set(
                            blockchain.ux.wallet.connect.session.details.disconnect.paragraph.button.primary.tap.then.emit,
                            to: blockchain.ux.wallet.connect.session.details.disconnect
                        )
                    }
                }
            }
            .padding(24)
            .onAppear {
                model.prepare(app: app, context: context)
            }
        }
    }
}

extension WalletConnectDetailsView {
    class Model: ObservableObject {
        @Published var details: EventDetails?

        func prepare(app: AppProtocol, context: Tag.Context) {
//            app.publisher(for: blockchain.ux.wallet.connect.session.details.model[].ref(to: context, in: app), as: WCSessionV2.self)
//                .compactMap(\.value)
//                .map { session -> EventDetails in
//                    EventDetails(
//                        name: session.peer.name,
//                        image: session.peer.icons.first ?? "",
//                        description: session.peer.description
//                    )
//                }
//                .assign(to: &$details)
        }
    }
}
