import BlockchainUI
import SwiftUI

public struct VeriffManualInputIntroductionView: View {

    @BlockchainApp var app

    var completion: () -> Void

    public var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 24.pt) {

                Icon.verified
                    .color(.semantic.title)
                    .circle(backgroundColor: Color.semantic.background)
                    .large()
                    .padding(.top)

                VStack(spacing: 8.pt) {
                    Text(L10n.getYouVerified)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(L10n.protectYourAccount)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                }

                HStack {
                    Icon.clockFilled
                        .micro()
                        .color(.semantic.primary)
                    Text(L10n.aboutTwoMinutes)
                        .foregroundTexture(.semantic.title)
                        .typography(.caption2)
                }
                .padding(6.pt)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.semantic.background)
                )

                DividedVStack {
                    Text(L10n.requireDateOfBirth)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(L10n.requireName)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(L10n.requireAddress)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(L10n.requireSSN)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .typography(.paragraph1)
                .foregroundTexture(.semantic.title)
                .padding([.top, .bottom], 8.pt)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.semantic.background)
                )
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            VStack(spacing: 16.pt) {
                PrimaryButton(
                    title: L10n.verifyMyID,
                    action: {
                        completion()
                    }
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light)
        .onAppear {
            $app.post(event: blockchain.ux.kyc.verify.with.veriff.introduction)
        }
    }
}

struct VeriffManualInputIntroductionView_Preview: PreviewProvider {
    static var previews: some View {
        VeriffManualInputIntroductionView(completion: { print(#fileID) })
    }
}
