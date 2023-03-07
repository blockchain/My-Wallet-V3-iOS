// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

private typealias L10n = LocalizationConstants.CardDetailsScreen.CreditCardDisclaimer

struct VGSAddCardFooterView: View {

    @BlockchainApp var app
    @Environment(\.openURL) var openURL

    var body: some View {
        AlertCard(
            title: L10n.title,
            message: L10n.message,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: L10n.button,
                        action: learnMore
                    )
                    Spacer()
                }
            }
        )
    }

    func learnMore() {
        Task { @MainActor in
            try await openURL(app.get(blockchain.ux.transaction.configuration.link.a.card.credit.card.learn.more.url))
        }
    }
}
