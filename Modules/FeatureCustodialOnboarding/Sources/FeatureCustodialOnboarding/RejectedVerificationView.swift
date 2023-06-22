import BlockchainUI
import SwiftUI

public struct RejectedVerificationView: View {

    @BlockchainApp var app

    public init() { }

    public var body: some View {
        VStack(spacing: 16.pt) {
            VStack(spacing: 24.pt) {
                Icon.user
                    .circle(backgroundColor: Color.semantic.light)
                    .iconColor(.semantic.title)
                    .frame(maxWidth: 88.pt, maxHeight: 88.pt)
                    .overlay(
                        Icon.alert
                            .color(.semantic.warning)
                            .circle(backgroundColor: Color.semantic.background)
                            .padding(2.pt)
                            .frame(width: 36.pt, height: 36.pt),
                        alignment: .bottomTrailing
                    )
                VStack(spacing: 8.pt) {
                    Text(L10n.weCouldNotVerify)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(L10n.unableToVerifyGoToDeFi)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                }
                .multilineTextAlignment(.center)
            }
            PrimaryButton(
                title: L10n.goToDeFi,
                action: {
                    $app.post(event: blockchain.ux.user.custodial.onboarding.rejected.verification.go.to.DeFi.paragraph.button.primary.tap)
                }
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.semantic.background)
        )
        .padding()
        .batch {
            set(blockchain.ux.user.custodial.onboarding.rejected.verification.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            set(blockchain.ux.user.custodial.onboarding.rejected.verification.go.to.DeFi.paragraph.button.primary.tap.then.set.session.state, to: [
                [
                    "key": blockchain.app.mode[],
                    "value": "PKW"
                ]
            ])
        }
    }
}
