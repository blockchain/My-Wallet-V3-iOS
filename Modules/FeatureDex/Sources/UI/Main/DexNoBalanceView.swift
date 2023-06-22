// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI

@available(iOS 15.0, *)
public struct DexNoBalanceView: View {

    @BlockchainApp var app
    @Environment(\.dismiss) var dismiss
    @State private var width: CGFloat = 0


    private let model: Model
    private var id = blockchain.ux.currency.exchange.dex.no.balance.sheet

    public init(networkTicker: String) {
        model = Model(networkTicker: networkTicker)
    }

    @ViewBuilder
    public var body: some View {
        VStack(spacing: 32) {
            HStack(alignment: .top) {
                Spacer()
                IconButton(icon: .closeCirclev2.small()) {
                    $app.post(event: id.entry.paragraph.button.icon.tap)
                }
                .batch {
                    set(id.entry.paragraph.button.icon.tap.then.close, to: true)
                }
            }
            AsyncMedia(url: model.nativeAsset?.logoURL)
                .resizingMode(.aspectFit)
                .frame(width: 96, height: 96)
                .fixedSize()
            VStack(spacing: 16) {
                Text(L10n.Main.NoBalanceSheet.title.interpolating(model.networkName))
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(L10n.Main.NoBalanceSheet.body.interpolating(model.networkName, model.assetName))
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
                    .frame(width: width)
            }
            .multilineTextAlignment(.center)
            PrimaryButton(title: L10n.Main.NoBalanceSheet.button) {
                app.post(
                    event: id.paragraph.row.tap,
                    context: [
                        blockchain.ux.asset.id: model.assetCode,
                        blockchain.coin.core.account.id: model.assetCode,
                        blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                    ]
                )
            }
        }
        .background(
            GeometryReader { proxy -> Color in
                let rect = proxy.frame(in: .global)
                DispatchQueue.main.async {
                    width = rect.width
                }
                return Color.semantic.background
            }
        )
        .padding(Spacing.padding2)
        .batch {
            set(id.paragraph.row.tap.then.close, to: true)
            set(id.paragraph.row.tap.then.emit, to: blockchain.ux.currency.exchange.dex.no.balance.show.receive)
            set(
                blockchain.ux.currency.exchange.dex.no.balance.show.receive.then.enter.into,
                to: blockchain.ux.currency.receive.address
            )
        }
    }
}

@available(iOS 15.0, *)
extension DexNoBalanceView {
    struct Model {

        private let network: EVMNetwork?

        var networkName: String {
            network?.networkConfig.shortName ?? ""
        }

        var assetName: String {
            network?.nativeAsset.name ?? ""
        }

        var assetCode: String {
            network?.nativeAsset.code ?? ""
        }

        var nativeAsset: CryptoCurrency? {
            network?.nativeAsset
        }

        init(networkTicker: String) {
            let service = EnabledCurrenciesService.default
            network = service
                .allEnabledEVMNetworks
                .first(where: { $0.networkConfig.networkTicker == networkTicker })
        }
    }
}
