// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// SecondaryButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `SecondaryButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)

public struct SecondaryButton<LeadingView: View>: View {

    private let title: String?
    private let isLoading: Bool
    private let leadingView: LeadingView
    private let action: () -> Void

    @Environment(\.pillButtonSize) private var size
    @Environment(\.isEnabled) private var isEnabled

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: .palette.grey800,
            border: .clear
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .palette.white,
            background: .palette.grey900,
            border: .clear
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.white.opacity(0.7),
                dark: .palette.white.opacity(0.4)
            ),
            background: Color(
                light: .palette.grey500,
                dark: .palette.dark800
            ),
            border: .clear
        ),
        progressViewRail: .palette.white.opacity(0.8),
        progressViewTrack: .palette.white.opacity(0.25)
    )

    public init(
        title: String?,
        isLoading: Bool = false,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.leadingView = leadingView()
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Spacing.padding2) {
                leadingView
                    .frame(width: 24, height: 24)

                if let title {
                    Text(title)
                }
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

extension SecondaryButton where LeadingView == EmptyView {

    /// Create a secondary button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap
    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            leadingView: { EmptyView() },
            action: action
        )
    }
}

struct SecondaryButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            SecondaryButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            SecondaryButton(title: "With Icon", leadingView: { Icon.placeholder }, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("With Icon")

            SecondaryButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            SecondaryButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}
