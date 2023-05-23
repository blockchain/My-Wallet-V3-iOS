// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import Localization
import SwiftUI

struct TotalBalanceView: View {
    @Environment(\.isSmallDevice) var isSmallDevice
    let balance: MoneyValue?

    var body: some View {
        if let balance {
            HStack {
                Text(LocalizationConstants.SuperApp.AppChrome.totalBalance)
                    .typography(isSmallDevice ? .caption1 : .paragraph1)
                    .opacity(0.8)
                balance.allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .typography(.paragraph2)
            }
            .foregroundColor(.white)
            .padding(.vertical, Spacing.padding1 * 0.5)
            .padding(.horizontal, Spacing.padding1)
            .overlay(
                Capsule()
                    .stroke(.white, lineWidth: 1)
                    .opacity(0.4)
            )
        }
    }
}

// MARK: - Previews

struct TotalBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TotalBalanceView(
                balance: .create(major: 11000.00, currency: .fiat(.GBP))
            )
            .padding()
            .background(Color.gray)
            TotalBalanceView(
                balance: .create(major: 11000.00, currency: .fiat(.GBP))
            )
            .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
