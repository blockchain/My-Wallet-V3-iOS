// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// MinimalButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `MinimalButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)
public struct MinimalButton<LeadingView: View>: View {

    @Binding var title: String
    private let isLoading: Bool
    private let isOpaque: Bool
    private let foregroundColor: Color
    private let leadingView: LeadingView
    private let action: () -> Void

    @Environment(\.pillButtonSize) private var size
    @Environment(\.isEnabled) private var isEnabled

    private var colorCombination: PillButtonStyle.ColorCombination {
        .init(
            enabled: PillButtonStyle.ColorSet(
                foreground: foregroundColor,
                background: Color(light: .palette.white, dark: .palette.dark900).opacity(isOpaque ? 1 : 0),
                border: Color(light: .palette.grey000, dark: .palette.dark700)
            ),
            pressed: PillButtonStyle.ColorSet(
                foreground: foregroundColor,
                background: Color(light: .palette.blue000, dark: .palette.dark800),
                border: .semantic.primaryMuted
            ),
            disabled: PillButtonStyle.ColorSet(
                foreground: Color(
                    light: foregroundColor.opacity(0.7),
                    dark: .palette.grey600
                ),
                background: Color(light: .palette.white, dark: .palette.dark900),
                border: Color(light: .palette.grey000, dark: .palette.dark800)
            ),
            progressViewRail: .semantic.primary,
            progressViewTrack: Color(
                light: .semantic.blueBG,
                dark: .palette.white.opacity(0.25)
            )
        )
    }

    public init(
        title: String,
        isLoading: Bool = false,
        isOpaque: Bool = true,
        foregroundColor: Color = .semantic.primary,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () -> Void
    ) {
        _title = .constant(title)
        self.isOpaque = isOpaque
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
        self.leadingView = leadingView()
        self.action = action
    }

    public init(
        title: Binding<String>,
        isLoading: Bool = false,
        isOpaque: Bool = false,
        foregroundColor: Color = .semantic.primary,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () -> Void
    ) {
        _title = title
        self.isOpaque = isOpaque
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
        self.leadingView = leadingView()
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Spacing.padding1) {
                leadingView
                    .frame(width: 24, height: 24)

                Text(title)
                    .typography(.body2)
            }
        }
        .buttonStyle(
            PillButtonStyle(
                isLoading: isLoading,
                isEnabled: isEnabled,
                size: size,
                colorCombination: colorCombination
            )
        )
    }
}

extension MinimalButton where LeadingView == EmptyView {

    /// Create a minimal button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap
    public init(
        title: String,
        isLoading: Bool = false,
        isOpaque: Bool = false,
        foregroundColor: Color = .semantic.primary,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            isOpaque: isOpaque,
            foregroundColor: foregroundColor,
            leadingView: { EmptyView() },
            action: action
        )
    }
}

struct MinimalButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            MinimalButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            MinimalButton(
                title: "With Icon",
                leadingView: {
                    Icon.placeholder
                },
                action: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("With Icon")

            MinimalButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            MinimalButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")

            MinimalButton(title: "Custom Text Color", foregroundColor: .semantic.error, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Custom Color")
        }
        .padding()
    }
}
