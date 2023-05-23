// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI

public struct AddressInfoModalView: View {

    typealias L10n = LocalizationConstants.Checkout.AddressInfoModal

    @BlockchainApp var app
    @Environment(\.context) var context

    private let address: String

    public init(address: String) {
        self.address = address
    }

    public var body: some View {
        VStack(spacing: Spacing.padding2) {
            HStack(alignment: .top) {
                Text(L10n.title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                Spacer()
                IconButton(icon: .closeCirclev2.small()) {
                    $app.post(event: blockchain.ux.transaction.send.address.info.entry.paragraph.button.icon.tap)
                }
                .batch {
                    set(blockchain.ux.transaction.send.address.info.entry.paragraph.button.icon.tap.then.close, to: true)
                }
            }
            VStack(spacing: Spacing.padding1) {
                Text(address)
                    .typography(.title3.mono())
                    .foregroundColor(.semantic.title)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity)
                Text(L10n.description)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
                    .multilineTextAlignment(.center)
                    .frame(maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)
            .padding(.vertical, Spacing.padding4)
            HStack {
                PrimaryButton(title: L10n.buttonTitle) {
                    $app.post(event: blockchain.ux.transaction.send.address.info.entry.paragraph.button.primary.tap)
                }
            }
            .batch {
                set(blockchain.ux.transaction.send.address.info.entry.paragraph.button.primary.tap.then.close, to: true)
            }
        }
        .padding(Spacing.padding2)
    }
}
