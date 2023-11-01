// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Syntactic suguar on MinimalButton to render it in a small size
///
/// # Usage
/// ```
/// SmallMinimalButton(title: "OK") { print("Tapped") }
/// ```
///
/// # Figma
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A2955)
public struct SmallMinimalButton<LeadingView: View>: View {

    @Binding var title: String
    private let isLoading: Bool
    private let foregroundColor: Color
    private let leadingView: LeadingView
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    private var colorCombination: PillButtonStyle.ColorCombination {
        minimalButtonColorCombination(foregroundColor: foregroundColor, isOpaque: true)
    }

    public init(
        title: String,
        isLoading: Bool = false,
        foregroundColor: Color = .semantic.primary,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () -> Void
    ) {
        _title = .constant(title)
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
        self.leadingView = leadingView()
        self.action = action
    }

    public init(
        title: Binding<String>,
        isLoading: Bool = false,
        foregroundColor: Color = .semantic.primary,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () -> Void
    ) {
        _title = title
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
        self.leadingView = leadingView()
        self.action = action
    }

    public init(
        title: String,
        isLoading: Bool = false,
        foregroundColor: Color = .semantic.primary,
        @ViewBuilder leadingView: () -> LeadingView,
        action: @escaping () async -> Void
    ) {
        _title = .constant(title)
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
        self.leadingView = leadingView()
        self.action = { Task(priority: .userInitiated) { @MainActor in await action() } }
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Spacing.padding1) {
                leadingView
                    .frame(width: 24, height: 24)
                Text(title)
                    .typography(.paragraph2)
            }
        }
        .buttonStyle(
            PillButtonStyle(
                isLoading: isLoading,
                isEnabled: isEnabled,
                size: .small,
                colorCombination: colorCombination
            )
        )
    }
}

extension SmallMinimalButton where LeadingView == EmptyView {

    /// Create a small minimal button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap
    public init(
        title: String,
        isLoading: Bool = false,
        foregroundColor: Color = .semantic.primary,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            foregroundColor: foregroundColor,
            leadingView: { EmptyView() },
            action: action
        )
    }

    public init(
        title: Binding<String>,
        isLoading: Bool = false,
        foregroundColor: Color = .semantic.primary,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            foregroundColor: foregroundColor,
            leadingView: { EmptyView() },
            action: action
        )
    }

    public init(
        title: String,
        isLoading: Bool = false,
        foregroundColor: Color = .semantic.primary,
        action: @escaping () async -> Void
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            foregroundColor: foregroundColor,
            leadingView: { EmptyView() },
            action: action
        )
    }
}

struct SmallMinimalButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallMinimalButton(
                title: "OK",
                isLoading: false,
                leadingView: {
                    Icon.coins.small()
                },
                action: {
                    print("Tapped")
                }
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            SmallMinimalButton(
                title: "OK",
                isLoading: false,
                leadingView: {
                    Icon.coins.small()
                },
                action: {
                    print("Tapped")
                }
            )
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            SmallMinimalButton(
                title: "OK",
                isLoading: true,
                leadingView: {
                    Icon.coins.small()
                },
                action: {
                    print("Tapped")
                }
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")
        }
    }
}
