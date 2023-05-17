// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Foundation
import SwiftUI

public struct WalletActionSheetView: View {
    let store: StoreOf<WalletActionSheet>
    @Environment(\.presentationMode) private var presentationMode

    public init(store: StoreOf<WalletActionSheet>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                headerView
                    .padding(.top, Spacing.padding1)
                    .padding(.bottom, Spacing.padding3)

                Text(viewStore.balanceString)
                    .typography(.title2)
                    .foregroundColor(.WalletSemantic.title)
                    .padding(
                        .leading,
                        Spacing.padding2
                    )
                    .padding(.bottom, Spacing.padding4)

                VStack {
                    ForEach(Array(viewStore.actionsToDisplay), id: \.self) { action in
                        Group {
                            PrimaryRow(
                                title: action.name,
                                subtitle: action.description,
                                leading: {
                                    action
                                        .icon?
                                        .circle(backgroundColor: .semantic.light)
                                        .color(.semantic.title)
                                        .frame(width: 32.pt)
                                },
                                action: {
                                    viewStore.send(.onActionTapped(action))
                                }
                            )
                            .frame(height: 74)
                            PrimaryDivider()
                        }
                    }
                }
            }
            .batch {
                set(
                    blockchain.ux.multiapp.wallet.action.sheet.deposit.paragraph.row.event.tap.then.emit,
                    to: blockchain.ux.frequent.action.deposit
                )
                set(
                    blockchain.ux.multiapp.wallet.action.sheet.withdraw.paragraph.row.event.tap.then.emit,
                    to: blockchain.ux.frequent.action.withdraw
                )
            }
            .background(Color.semantic.background.ignoresSafeArea())
        })
    }

    var headerView: some View {
        HStack(spacing: Spacing.padding1) {
            // Icon
            ViewStore(store).currencyIcon?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .background(Color.semantic.fiatGreen)
                .cornerRadius(6, corners: .allCorners)

            // Text
            Text(ViewStore(store).titleString)
                .typography(.body2)
                .foregroundColor(.semantic.title)
            Spacer()
            Icon.closeCirclev3
                .small()
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .padding(.horizontal, Spacing.padding2)
    }
}
