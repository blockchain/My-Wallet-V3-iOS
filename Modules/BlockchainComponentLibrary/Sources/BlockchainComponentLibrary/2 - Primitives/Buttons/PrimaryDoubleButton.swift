// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PrimaryDoubleButton from the Figma Component Library.
///
///
/// # Usage:
///
/// ```
/// PrimaryDoubleButton(`
///     leadingTitle: "leading button",
///     leadingAction: { print("leading button did tap") },
///     trailingTitle: "trailing button",
///     trailingAction: { print("trailing button did tap") }
/// )
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)
public struct PrimaryDoubleButton: View {

    private struct ButtonData {
        let title: String
        let isLoading: Bool
        let action: () -> Void
    }

    private let leadingButton: ButtonData
    private let trailingButton: ButtonData

    private let colorCombination: PillButtonStyle.ColorCombination = .primary

    @Environment(\.isEnabled) private var isEnabled

    public init(
        leadingTitle: String,
        leadingIsLoading: Bool = false,
        leadingAction: @escaping () -> Void,
        trailingTitle: String,
        trailingIsLoading: Bool = false,
        trailingAction: @escaping () -> Void
    ) {
        self.leadingButton = ButtonData(
            title: leadingTitle,
            isLoading: leadingIsLoading,
            action: leadingAction
        )
        self.trailingButton = ButtonData(
            title: trailingTitle,
            isLoading: trailingIsLoading,
            action: trailingAction
        )
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button(leadingButton.title, action: leadingButton.action)
                .buttonStyle(
                    PillButtonStyle(
                        isLoading: leadingButton.isLoading,
                        isEnabled: isEnabled,
                        isRounded: false,
                        colorCombination: colorCombination
                    )
                )
            Color(light: .palette.white, dark: .palette.white)
                .opacity(0.4)
                .frame(width: 1, height: 32)
            Button(trailingButton.title, action: trailingButton.action)
                .buttonStyle(
                    PillButtonStyle(
                        isLoading: trailingButton.isLoading,
                        isEnabled: isEnabled,
                        isRounded: false,
                        colorCombination: colorCombination
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius))
    }
}

struct PrimaryDoubleButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PrimaryDoubleButton(
                leadingTitle: "Leading",
                leadingAction: {},
                trailingTitle: "Trailing",
                trailingAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            PrimaryDoubleButton(
                leadingTitle: "Leading",
                leadingAction: {},
                trailingTitle: "Trailing",
                trailingAction: {}
            )
            .environment(\.layoutDirection, .rightToLeft)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled RTL")

            PrimaryDoubleButton(
                leadingTitle: "Disabled",
                leadingAction: {},
                trailingTitle: "Disabled",
                trailingAction: {}
            )
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            PrimaryDoubleButton(
                leadingTitle: "Loading",
                leadingIsLoading: true,
                leadingAction: {},
                trailingTitle: "Loading",
                trailingIsLoading: true,
                trailingAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")
        }
        .padding()
    }
}
