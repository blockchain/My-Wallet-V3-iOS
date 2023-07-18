// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Coincore
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import Localization
import SwiftUI

public struct FiatActionSheetView: View {
    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app
    private let model: Model
    public init(assetBalanceInfo: AssetBalanceInfo) {
        model = Model(with: assetBalanceInfo)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            headerView
            balance
            rows
        }
        .background(Color.semantic.background.ignoresSafeArea())
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
    }

    @ViewBuilder
    private var rows: some View {
        VStack {
            ForEach(Array(model.actionsToDisplay), id: \.self) { action in
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
                            if let namespaceAction = action.namespaceAction {
                                app.post(event: namespaceAction)
                            }
                        }
                    )
                    .frame(height: 74)
                    PrimaryDivider()
                }
            }
        }
    }

    @ViewBuilder
    private var balance: some View {
        if let balance = model.balanceString {
            Text(balance)
                .typography(.title2)
                .foregroundColor(.WalletSemantic.title)
                .padding(
                    .leading,
                    Spacing.padding2
                )
                .padding(.bottom, Spacing.padding4)
        }
    }

    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: Spacing.padding1) {
            // Icon
            model.currencyIcon?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .background(Color.semantic.fiatGreen)
                .cornerRadius(6, corners: .allCorners)

            // Text
            Text(model.titleString)
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
        .padding(.top, Spacing.padding1)
        .padding(.bottom, Spacing.padding3)
    }
}

extension FiatActionSheetView {

    struct Model: Equatable {
        private let asset: AssetBalanceInfo

        var actionsToDisplay: [AssetAction] {
            asset.sortedActions.filter(\.allowed)
        }

        var balanceString: String? {
            asset.balance?.toDisplayString(includeSymbol: true)
        }

        var titleString: String {
            asset.currency.name
        }

        var currencyIcon: Image? {
            asset.currency.fiatCurrency?.image
        }

        init(with asset: AssetBalanceInfo) {
            self.asset = asset
        }
    }
}


extension AssetAction {
    typealias LocalizationId = LocalizationConstants.WalletAction.Default

    var icon: Icon? {
        switch self {
        case .deposit:
            return Icon.bank
        case .withdraw:
            return Icon.cash
        default:
            return nil
        }
    }

    var name: String {
        switch self {
        case .deposit:
            return LocalizationId.Deposit.title
        case .withdraw:
            return LocalizationId.Withdraw.title
        default:
            return ""
        }
    }

    var description: String {
        switch self {
        case .deposit:
            return LocalizationId.Deposit.Fiat.description
        case .withdraw:
            return LocalizationId.Withdraw.description
        default:
            return ""
        }
    }

    var namespaceAction: Tag.Event? {
        switch self {
        case .deposit:
            return blockchain.ux.multiapp.wallet.action.sheet.deposit.paragraph.row.tap
        case .withdraw:
            return blockchain.ux.multiapp.wallet.action.sheet.withdraw.paragraph.row.tap
        default:
            return nil
        }
    }

    var allowed: Bool {
        switch self {
        case .deposit, .withdraw:
            return true
        default:
            return false
        }
    }
}
