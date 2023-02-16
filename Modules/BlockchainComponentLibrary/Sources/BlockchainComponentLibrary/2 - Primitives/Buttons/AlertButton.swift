// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

// MARK: - Public

/// AlertButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `AlertButton(title: "Alert") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)

public struct AlertButton: View {

    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.baseline) {
                Icon
                    .alert
                    .color(.palette.orange600)
                    .frame(width: 16)
                    .background(
                        Circle()
                            .foregroundColor(.palette.white)
                            .frame(width: 10)
                    )
                Text(title)
            }
        }
        .buttonStyle(
            AlertButtonStyle(isLoading: isLoading)
        )
    }
}

// MARK: - Internal

struct AlertButtonStyle: ButtonStyle {

    struct ColorSet {
        let foreground: Color
        let background: Color
    }

    struct ColorCombination {
        let enabled: ColorSet
        let pressed: ColorSet
        let progressViewRail: Color
        let progressViewTrack: Color
    }

    let isLoading: Bool

    private let colorCombination = ColorCombination(
        enabled: ColorSet(
            foreground: .palette.white,
            background: Color(
                light: .palette.grey900,
                dark: .palette.dark800
            )
        ),
        pressed: ColorSet(
            foreground: .palette.white,
            background: .palette.black
        ),
        progressViewRail: .palette.white.opacity(0.8),
        progressViewTrack: .palette.white.opacity(0.25)
    )

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(
                        BlockchainCircularProgressViewStyle(
                            stroke: colorCombination.progressViewRail,
                            background: colorCombination.progressViewTrack
                        )
                    )
                    .frame(width: 24, height: 24)
            } else {
                configuration
                    .label
                    .typography(.body2)
            }
        }
        .foregroundColor(colorSet(for: configuration).foreground)
        .frame(maxWidth: .infinity, minHeight: ButtonSize.Standard.height)
        .background(
            RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius)
                .fill(colorSet(for: configuration).background)
        )
    }

    private func colorSet(for configuration: Configuration) -> ColorSet {
        if configuration.isPressed {
            return colorCombination.pressed
        } else {
            return colorCombination.enabled
        }
    }
}

// MARK: - Previews

struct AlertButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AlertButton(title: "Enabled", action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            AlertButton(title: "Loading", isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}
