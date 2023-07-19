import BlockchainComponentLibrary
import BlockchainNamespace
import enum Localization.LocalizationConstants
import SwiftUI

struct CreditCardLearnMoreView: View {

    typealias L10n = LocalizationConstants.CardDetailsScreen.CreditCardDisclaimer

    @Environment(\.openURL) var openURL

    let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

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
        .padding()
    }

    func learnMore() {
        Task { @MainActor in
            try await openURL(app.get(blockchain.ux.transaction.configuration.link.a.card.credit.card.learn.more.url))
        }
    }
}
