// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI

struct BakktTermsAndConditionsView: View {
    @State var termsApproved: Bool = false
    var onDone: () -> Void
    var termsAndConditionsUrl: URL? {
        URL(string: "https://www.blockchain.com/legal/bakkt/terms")
    }

    var body: some View {
        VStack {
            if let url = termsAndConditionsUrl {
                WebView(url: url)
            }
            VStack(spacing: Spacing.padding2) {
                termsAndConditions

                PrimaryButton(title: LocalizationConstants.ExternalTradingMigration.continueButton) {
                    onDone()
                }
            }
        }
        .padding(.horizontal, Spacing.padding2)
    }

    @ViewBuilder var termsAndConditions: some View {
        HStack {
            Checkbox(isOn: $termsApproved)
            Text(LocalizationConstants.ExternalTradingMigration.TermsAndConditions.disclaimer)
                .typography(.micro)
                .foregroundColor(.semantic.body)
        }
    }
}
//
//#Preview {
//    BakktTermsAndConditionsView(onDone: {})
//}
