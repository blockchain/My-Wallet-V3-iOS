import BlockchainUI
import SwiftUI

public struct VerificationInProgressView: View {

    @BlockchainApp var app

    public init() { }

    public var body: some View {
        VStack(spacing: 16.pt) {
            VStack(spacing: 24.pt) {
                Icon.user
                    .circle(backgroundColor: Color.semantic.background)
                    .iconColor(.semantic.title)
                    .frame(maxWidth: 88.pt, maxHeight: 88.pt)
                    .overlay(
                        Icon.clock
                            .medium()
                            .color(.semantic.muted)
                            .circle(backgroundColor: Color.semantic.light)
                            .padding(2.pt),
                        alignment: .bottomTrailing
                    )
                VStack(spacing: 16.pt) {
                    Text(L10n.applicationSubmitted)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(L10n.successfullyReceivedInformation)
                        .lineLimit(nil)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                }
                .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            PrimaryButton(
                title: L10n.ok,
                action: {
                    $app.post(event: blockchain.ux.user.custodial.onboarding.verification.is.in.progress.ok.paragraph.button.primary.tap)
                }
            )
        }
        .padding(.top, 40.pt)
        .overlay(
            IconButton(
                icon: .closev2.small().color(.semantic.muted).circle(backgroundColor: .semantic.background),
                action: { $app.post(event: blockchain.ux.user.custodial.onboarding.verification.is.in.progress.article.plain.navigation.bar.button.close.tap) }
            ),
            alignment: .topTrailing
        )
        .padding(.top)
        .padding(.horizontal, 24.pt)
        .background(Color.semantic.light.ignoresSafeArea())
        .batch {
            set(blockchain.ux.user.custodial.onboarding.verification.is.in.progress.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            set(blockchain.ux.user.custodial.onboarding.verification.is.in.progress.ok.paragraph.button.primary.tap.then.close, to: true)
        }
    }
}

struct VerificationInProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationInProgressView()
            .app(App.preview)
    }
}
