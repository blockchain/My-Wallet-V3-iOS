// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI

public struct SweepImportedAddressesNoActionView: View {
    typealias L10n = LocalizationConstants.NoSweepNeeded

    @BlockchainApp var app

    public var body: some View {
        VStack(spacing: Spacing.padding1) {
            HStack(alignment: .top) {
                Text(L10n.title)
                    .typography(.body1)
                    .foregroundColor(.semantic.title)
                Spacer()
                IconButton(icon: .navigationCloseButton()) {
                    $app.post(event: blockchain.ux.sweep.imported.addresses.no.action.entry.paragraph.button.icon.tap)
                }
                .batch {
                    set(blockchain.ux.sweep.imported.addresses.no.action.entry.paragraph.button.icon.tap.then.close, to: true)
                }
            }
            VStack(spacing: Spacing.padding1) {
                Icon.checkCircle
                    .with(length: 64.pt)
                    .color(.semantic.success)
                VStack(spacing: Spacing.padding1) {
                    Text(L10n.subtitle)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                        .padding(.bottom, Spacing.padding1)
                    Text(L10n.subtitle2)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, Spacing.padding2)
            PrimaryButton(title: L10n.thanks) {
                $app.post(event: blockchain.ux.sweep.imported.addresses.no.action.entry.paragraph.button.primary.tap)
            }
            .padding(.horizontal, Spacing.padding2)
            .padding(.bottom, Spacing.padding2)
            .batch {
                set(blockchain.ux.sweep.imported.addresses.no.action.entry.paragraph.button.primary.tap.then.close, to: true)
            }
        }
        .padding(Spacing.padding2)
    }
}
