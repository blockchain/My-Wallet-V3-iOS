// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI

public struct DefiBuyCryptoMessageView: View {
    typealias L10n = LocalizationConstants.DefiBuyCryptoSheet

    @Environment(\.presentationMode) private var presentationMode
    let onOpenTradingModeTap: () -> Void

    public init(onOpenTradingModeTap: @escaping () -> Void) {
        self.onOpenTradingModeTap = onOpenTradingModeTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {

            Text(L10n.message.interpolating(NonLocalizedConstants.defiWalletTitle, NonLocalizedConstants.defiWalletTitle))
                .typography(.body1)
                .padding(.horizontal, Spacing.padding3)

            PrimaryButton(
                title: "Open Blockchain.com Account",
                isLoading: false
            ) {
                presentationMode.wrappedValue.dismiss()
                onOpenTradingModeTap()
            }
                          .padding(.horizontal, Spacing.padding3)
        }
        .frame(minHeight: 200)
    }
}

struct DefiBuyCryptoMessageView_Previews: PreviewProvider {
    static var previews: some View {
        DefiBuyCryptoMessageView(onOpenTradingModeTap: {})
    }
}
