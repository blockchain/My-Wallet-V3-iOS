// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import FeatureDashboardDomain
import SwiftUI

struct DashboardAssetRowView: View {
    @BlockchainApp var app
    let store: StoreOf<DashboardAssetRow>

    init(store: StoreOf<DashboardAssetRow>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            Group {
                if viewStore.type == .fiat {
                    SimpleBalanceRow(
                        leadingTitle: viewStore.asset.currency.name,
                        trailingTitle: viewStore.trailingTitle,
                        trailingDescription: viewStore.trailingDescriptionString,
                        trailingDescriptionColor: Color.semantic.body,
                        action: {
                            app.post(
                                event: blockchain.ux.dashboard.fiat.account.tap,
                                context: [
                                    blockchain.ux.dashboard.fiat.account.action.sheet.asset.id: viewStore.asset.currency.code,
                                    blockchain.ux.dashboard.fiat.account.action.sheet.asset: viewStore.asset,
                                    blockchain.ui.type.action.then.enter.into.detents: [
                                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                                    ]
                                ]
                            )
                        },
                        leading: {
                            viewStore.asset.currency.fiatCurrency?
                                .image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .background(Color.WalletSemantic.fiatGreen)
                                .cornerRadius(6, corners: .allCorners)
                        }
                    )
                } else {
                    SimpleBalanceRow(
                        leadingTitle: viewStore.asset.currency.name,
                        trailingTitle: viewStore.asset.fiatBalance?.quote.toDisplayString(includeSymbol: true),
                        trailingDescription: viewStore.trailingDescriptionString,
                        trailingDescriptionColor: viewStore.trailingDescriptionColor,
                        action: {
                            viewStore.send(.onAssetTapped)
                        },
                        leading: {
                            iconView(for: viewStore.asset)
                        }
                    )
                }

                if viewStore.isLastRow == false {
                    Divider()
                        .foregroundColor(.WalletSemantic.light)
                }
            }
            .batch {
                set(
                    blockchain.ux.dashboard.fiat.account.tap.then.enter.into,
                    to: blockchain.ux.dashboard.fiat.account.action.sheet
                )
            }
        })
    }

    @ViewBuilder
    func iconView(for balanceInfo: AssetBalanceInfo) -> some View {
        if #available(iOS 15.0, *) {
            ZStack(alignment: .bottomTrailing) {
                AsyncMedia(url: balanceInfo.currency.cryptoCurrency?.assetModel.logoPngUrl, placeholder: { EmptyView() })
                    .frame(width: 24.pt, height: 24.pt)
                    .background(Color.WalletSemantic.light, in: Circle())

                if let network = balanceInfo.network,
                    balanceInfo.currency.code != network.nativeAsset.code
                {
                    ZStack(alignment: .center) {
                        AsyncMedia(url: network.nativeAsset.assetModel.logoPngUrl, placeholder: { EmptyView() })
                            .frame(width: 12.pt, height: 12.pt)
                            .background(Color.WalletSemantic.background, in: Circle())
                        Circle()
                            .strokeBorder(Color.WalletSemantic.background, lineWidth: 1)
                            .frame(width: 13, height: 13)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct DashboardAssetRowView_Previews: PreviewProvider {
    static var previews: some View {
        let assetBalanceInfo = AssetBalanceInfo(
            cryptoBalance: .one(currency: .USD),
            fiatBalance: nil,
            currency: .crypto(.bitcoin),
            delta: nil,
            rawQuote: nil
        )
        DashboardAssetRowView(store: .init(initialState: .init(
            type: .custodial,
            isLastRow: false,
            asset: assetBalanceInfo
        ), reducer: DashboardAssetRow(app: resolve())))
    }
}
