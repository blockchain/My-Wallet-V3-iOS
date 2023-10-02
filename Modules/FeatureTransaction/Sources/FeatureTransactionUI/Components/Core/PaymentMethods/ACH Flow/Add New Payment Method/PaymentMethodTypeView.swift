import BlockchainComponentLibrary
import SwiftUI

/// BankAccountPaymentMethodView
///
/// # Figma
///
/// [PaymentMethodTypeView](https://www.figma.com/file/t5kbDT2sglqHuWyW1wZ7Dj/Q4-Bugs?node-id=432%3A21840)
struct PaymentMethodTypeView: View, Equatable {

    private typealias Spacing = BlockchainComponentLibrary.Spacing

    private let title: String
    private let subtitle: String
    private let message: String
    private let onViewTapped: () -> Void
    private let isEnabled: Bool

    /// Create a PaymentMethodTypeView
    /// - Parameters:
    ///   - title: Text displayed in the card as a title
    ///   - subtitle: Subtitle text displayed on the card
    ///   - message: Main text displayed on the card
    ///   - accessibilityIdentifier: Accessibility ID
    ///   - onViewTapped: Closure called when view is tapped
    init(
        title: String,
        subtitle: String,
        message: String,
        accessibilityIdentifier: String,
        onViewTapped: @escaping () -> Void,
        isEnabled: Bool
    ) {
        self.title = title
        self.message = message
        self.subtitle = subtitle
        self.onViewTapped = onViewTapped
        self.isEnabled = isEnabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                    Text(subtitle)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                }

                Spacer()
                Image("icon-disclosure-small", bundle: .platformUIKit)
                    .frame(width: 12.0, height: 12.0)
            }

            Text(message)
                .typography(.caption1)
                .foregroundColor(.semantic.body)
        }
        .padding(Spacing.padding3)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(.semantic.medium)
        )
        .padding(Spacing.padding3)
        .contentShape(Rectangle())
        .onTapGesture {
            onViewTapped()
        }
        .accessibility(identifier: "")
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

extension PaymentMethodTypeView {
    static func == (
        lhs: PaymentMethodTypeView,
        rhs: PaymentMethodTypeView
    ) -> Bool {
        lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.message == rhs.message
    }
}
