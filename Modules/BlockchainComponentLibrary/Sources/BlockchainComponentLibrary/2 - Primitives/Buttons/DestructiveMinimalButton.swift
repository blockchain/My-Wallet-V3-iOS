// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// DestructiveMinimalButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `DestructiveMinimalButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)

public struct DestructiveMinimalButton: View {
    public enum Variant {
        case white
        case gray
    }

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool
    private let variant: Variant

    @Environment(\.isEnabled) private var isEnabled

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .semantic.error,
            background: .clear,
            border: Color(
                light: .palette.grey100,
                dark: .palette.dark300
            )
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.error,
            background: Color(
                light: .palette.red000,
                dark: .palette.dark800
            ),
            border: .semantic.error
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: .palette.red600,
            background: .clear,
            border: Color(
                light: .semantic.light,
                dark: .palette.grey700
            )
        ),
        progressViewRail: .semantic.error,
        progressViewTrack: Color(
            light: .semantic.redBG,
            dark: .palette.white.opacity(0.25)
        )
    )

    private let whiteColorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .semantic.error,
            background: .white,
            border: .semantic.light
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.error,
            background: Color(
                light: .palette.red000,
                dark: .palette.dark800
            ),
            border: .semantic.error
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: .palette.red600,
            background: .clear,
            border: Color(
                light: .semantic.light,
                dark: .palette.grey700
            )
        ),
        progressViewRail: .semantic.error,
        progressViewTrack: Color(
            light: .semantic.redBG,
            dark: .palette.white.opacity(0.25)
        )
    )

    /// Create a DestructivePrimary Button
    /// - Parameters:
    ///   - title: Title of the button
    ///   - isLoading: Bool to show a progress view instead of the button title
    ///   - action: Action to execute on button tap
    public init(
        title: String,
        isLoading: Bool = false,
        variant: Variant = .gray,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
        self.variant = variant
    }

    public var body: some View {
        Button(title) {
            action()
        }
        .buttonStyle(
            PillButtonStyle(
                isLoading: isLoading,
                isEnabled: isEnabled,
                size: .standard,
                colorCombination: variant == .white ? whiteColorCombination : colorCombination
            )
        )
    }
}

struct DestructiveMinimalButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            DestructiveMinimalButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            DestructiveMinimalButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            DestructiveMinimalButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}
