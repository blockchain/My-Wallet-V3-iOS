import BlockchainUI
import SwiftUI

struct TooltipView: View {

    let title: String
    let message: String
    let dismiss: () -> Void

    @ViewBuilder
    var body: some View {
        VStack(spacing: 24.pt) {
            Spacer()
                .frame(height: 1)
            VStack(spacing: 8.pt) {
                Text(title)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(message)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
            PrimaryButton(title: L10n.Tooltip.gotIt) {
                dismiss()
            }
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}
