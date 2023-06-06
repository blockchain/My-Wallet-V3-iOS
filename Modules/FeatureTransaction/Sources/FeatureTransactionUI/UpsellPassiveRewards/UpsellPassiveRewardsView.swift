//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import BlockchainUI

public struct UpsellPassiveRewardsView: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    @State var swappedCurrency: CryptoCurrency?

    public init () {}

    public var body: some View {
        ZStack {
            Color
                .WalletSemantic
                .light
                .ignoresSafeArea()
            contentView
        }
        .bindings {
            subscribe($swappedCurrency , to: blockchain.ux.transaction.source.target.id)
        }
    }

    private var contentView: some View {
        VStack {
            swappedCurrency?.logo(size: 88.pt)
                .padding(.bottom, Spacing.padding3)

            Text("Put your Asset \(swappedCurrency?.name ?? "") To Work")
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.bottom, Spacing.padding1)

            Text("With Passive Rewards, you can earn up to |X|% on your |ASSET|.")
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding3)


            SmallMinimalButton(title: "Learn More") {

            }

            Spacer()

            ctaButtons
        }
        .padding(Spacing.padding2)
    }

    private var ctaButtons: some View {
        VStack(spacing: Spacing.padding2) {
            PrimaryButton(title: "Start earning") {

            }
            SecondaryButton(title: "Maybe Later") {

            }
        }
        .padding(.bottom, Spacing.padding4)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        UpsellPassiveRewardsView()
    }
}
