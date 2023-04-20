// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// PrimaryWhiteButton used in Referal Welcome
///
///
/// # Usage:
///
/// `PrimaryWhiteButton(title: "Tap me") { print("button did tap") }`
///
/// - Version: 1.0.1
///

public struct PrimaryWhiteButton<LeadingView: View>: View {

    private let title: String
    private let isLoading: Bool
    private let leadingView: () -> LeadingView
    private let action: () -> Void

    public init(
        title: String,
        isLoading: Bool = false,
        @ViewBuilder leadingView: @escaping () -> LeadingView,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.leadingView = leadingView
        self.action = action
    }

    public var body: some View {
        DefaultButton(
            title: title,
            isLoading: isLoading,
            leadingView: leadingView,
            action: action
        )
        .colorCombination(.white)
    }
}

extension PrimaryWhiteButton where LeadingView == EmptyView {

    /// Create a primary button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap
    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            leadingView: { EmptyView() },
            action: action
        )
    }

    /// Create a primary button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap wrapped in Task
    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () async -> Void = {}
    ) {
        self.init(
            title: title,
            isLoading: isLoading,
            leadingView: { EmptyView() },
            action: { Task(priority: .userInitiated) { @MainActor in await action() } }
        )
    }
}

extension PillButtonStyle.ColorCombination {

    public static let white = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .palette.blue600,
            background: .palette.white,
            border: .clear
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .palette.blue700,
            background: .palette.white,
            border: .clear
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.blue600.opacity(0.7),
                dark: .palette.blue600.opacity(0.4)
            ),
            background: Color(
                light: .palette.white,
                dark: .palette.white
            ),
            border: .clear
        ),
        progressViewRail: .palette.blue600.opacity(0.8),
        progressViewTrack: .palette.blue600.opacity(0.25)
    )
}

struct PrimaryWhiteButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BuyButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            BuyButton(title: "Disabled", action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            BuyButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}
