// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct DashboardHelpSectionView: View {
    @BlockchainApp var app

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(LocalizationConstants.SuperApp.Dashboard.helpSectionHeader)
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                Spacer()
            }
            .padding(.vertical, Spacing.padding1)
            VStack(spacing: 0) {
                PrimaryRow(
                    title: LocalizationConstants.SuperApp.Help.chat,
                    textStyle: .superApp,
                    trailing: { trailingView }
                ) {
                    app.post(event: blockchain.ux.customer.support.show.messenger)
                }
                PrimaryDivider()
                PrimaryRow(
                    title: LocalizationConstants.SuperApp.Help.supportCenter,
                    textStyle: .superApp,
                    trailing: { trailingView }
                ) {
                    app.post(event: blockchain.ux.customer.support.show.help.center)
                }
            }
            .cornerRadius(16, corners: .allCorners)
        }
        .padding(.horizontal, Spacing.padding2)
    }

    @ViewBuilder var trailingView: some View {
        Icon.chevronRight
            .color(Color.black)
            .frame(height: 18)
            .flipsForRightToLeftLayoutDirection(true)
    }
}
