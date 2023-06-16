import BlockchainUI
import SwiftUI

public struct BeforeYouContinuePleaseVerifyView: View {

    @BlockchainApp var app

    public init() { }

    public var body: some View {
        VStack(spacing: 16.pt) {
            VStack(spacing: 24.pt) {
                Icon.user
                    .circle(backgroundColor: Color.semantic.light)
                    .iconColor(.semantic.title)
                    .frame(maxWidth: 88.pt, maxHeight: 88.pt)
                VStack(spacing: 8.pt) {
                    Text(L10n.beforeYouContinue)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(L10n.startTradingCrypto)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                }
                .multilineTextAlignment(.center)
                HStack {
                    Icon.clock.micro().color(.semantic.primary)
                    Text(L10n.completeIn2Minutes)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.primary)
                }
                .padding(8.pt)
                .background(
                    Capsule().strokeBorder(Color.semantic.light)
                )
            }
            PrimaryButton(
                title: L10n.verifyMyIdentity,
                action: {
                    $app.post(event: blockchain.ux.user.custodial.onboarding.before.you.continue.verify.identity.paragraph.button.primary.tap)
                }
            )
        }
        .padding(.top, 40.pt)
        .overlay(
            IconButton(
                icon: .closev2.small().color(.semantic.muted).circle(backgroundColor: .semantic.light),
                action: { $app.post(event: blockchain.ux.user.custodial.onboarding.before.you.continue.article.plain.navigation.bar.button.close.tap) }
            ),
            alignment: .topTrailing
        )
        .padding(.top)
        .padding(.horizontal)
        .background(Color.semantic.background)
        .batch {
            set(blockchain.ux.user.custodial.onboarding.before.you.continue.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            set(blockchain.ux.user.custodial.onboarding.before.you.continue.verify.identity.paragraph.button.primary.tap.then.close, to: true)
            set(blockchain.ux.user.custodial.onboarding.before.you.continue.verify.identity.paragraph.button.primary.tap.then.emit, to: blockchain.ux.kyc.launch.verification[])
        }
    }
}

struct BeforeYouContinuePleaseVerifyView_Previews: PreviewProvider {
    static var previews: some View {
        BeforeYouContinuePleaseVerifyView()
            .app(App.preview)
    }
}
