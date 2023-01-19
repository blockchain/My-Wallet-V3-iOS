// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// MinimalDoubleButton from the Figma Component Library.
///
///
/// # Usage:
///
/// ```
/// MinimalDoubleButton(`
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
public struct MinimalDoubleButton<LeadingLeadingView: View, TrailingLeadingView: View>: View {

    private let leadingButton: ButtonData<LeadingLeadingView>
    private let trailingButton: ButtonData<TrailingLeadingView>

    @Environment(\.isEnabled) private var isEnabled

    public init(
        leadingTitle: String,
        leadingIsLoading: Bool = false,
        @ViewBuilder leadingLeadingView: @escaping () -> LeadingLeadingView,
        leadingAction: @escaping () -> Void,
        trailingTitle: String,
        trailingIsLoading: Bool = false,
        @ViewBuilder trailingLeadingView: @escaping () -> TrailingLeadingView,
        trailingAction: @escaping () -> Void
    ) {
        self.leadingButton = ButtonData(
            title: leadingTitle,
            isLoading: leadingIsLoading,
            leadingView: leadingLeadingView,
            action: leadingAction
        )
        self.trailingButton = ButtonData(
            title: trailingTitle,
            isLoading: trailingIsLoading,
            leadingView: trailingLeadingView,
            action: trailingAction
        )
    }

    public var body: some View {
        Button(action: {}, label: {})
            .buttonStyle(
                MinimalDoubleButtonStyle(
                    isEnabled: isEnabled,
                    leadingButton: leadingButton,
                    trailingButton: trailingButton
                )
            )
    }
}

private struct ButtonData<LeadingView: View> {
    let title: String
    let isLoading: Bool
    let leadingView: () -> LeadingView
    let action: () -> Void
}

private struct MinimalDoubleButtonStyle<LeadingLeadingView: View, TrailingLeadingView: View>: ButtonStyle {

    let isEnabled: Bool
    let leadingButton: ButtonData<LeadingLeadingView>
    let trailingButton: ButtonData<TrailingLeadingView>

    private let colorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .semantic.primary,
            background: Color(
                light: .palette.white,
                dark: .clear
            ),
            border: Color(
                light: .palette.white,
                dark: .clear
            )
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.primary,
            background: .semantic.light,
            border: .semantic.light
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .semantic.primary.opacity(0.7),
                dark: .palette.grey600
            ),
            background: Color(
                light: .palette.white,
                dark: .palette.white.opacity(0)
            ),
            border: Color(
                light: .palette.white,
                dark: .palette.white.opacity(0)
            )
        ),
        progressViewRail: .semantic.primary,
        progressViewTrack: Color(
            light: .semantic.blueBG,
            dark: .palette.white.opacity(0.25)
        )
    )

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            Button(action: leadingButton.action) {
                HStack(spacing: Spacing.padding2) {
                    leadingButton.leadingView()
                        .frame(width: 24, height: 24)

                    Text(leadingButton.title)
                }
            }
            .buttonStyle(
                PillButtonStyle(
                    isLoading: leadingButton.isLoading,
                    isEnabled: isEnabled,
                    isRounded: false,
                    colorCombination: colorCombination
                )
            )
            borderColor(for: configuration)
                .frame(width: 1, height: 32)
            Button(action: trailingButton.action) {
                HStack(spacing: Spacing.padding2) {
                    trailingButton.leadingView()
                        .frame(width: 24, height: 24)

                    Text(trailingButton.title)
                }
            }
            .buttonStyle(
                PillButtonStyle(
                    isLoading: trailingButton.isLoading,
                    isEnabled: isEnabled,
                    isRounded: false,
                    colorCombination: colorCombination
                )
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius)
                .stroke(borderColor(for: configuration))
        )
        .clipShape(RoundedRectangle(cornerRadius: ButtonSize.Standard.cornerRadius))
    }

    private func borderColor(for configuration: Configuration) -> Color {
        if configuration.isPressed {
            return Color.semantic.primary
        } else if isEnabled {
            return Color(
                light: .semantic.medium,
                dark: .palette.dark300
            )
        } else {
            return Color(
                light: .semantic.light,
                dark: .palette.grey700
            )
        }
    }
}

extension MinimalDoubleButton where LeadingLeadingView == EmptyView, TrailingLeadingView == EmptyView {
    public init(
        leadingTitle: String,
        leadingIsLoading: Bool = false,
        leadingAction: @escaping () -> Void,
        trailingTitle: String,
        trailingIsLoading: Bool = false,
        trailingAction: @escaping () -> Void
    ) {
        self.init(
            leadingTitle: leadingTitle,
            leadingIsLoading: leadingIsLoading,
            leadingLeadingView: EmptyView.init,
            leadingAction: leadingAction,
            trailingTitle: trailingTitle,
            trailingIsLoading: trailingIsLoading,
            trailingLeadingView: EmptyView.init,
            trailingAction: trailingAction
        )
    }
}

struct MinimalDoubleButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            MinimalDoubleButton(
                leadingTitle: "Leading",
                leadingAction: {},
                trailingTitle: "Trailing",
                trailingAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            MinimalDoubleButton(
                leadingTitle: "Leading",
                leadingAction: {},
                trailingTitle: "Trailing",
                trailingAction: {}
            )
            .environment(\.layoutDirection, .rightToLeft)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled RTL")

            MinimalDoubleButton(
                leadingTitle: "Disabled",
                leadingAction: {},
                trailingTitle: "Disabled",
                trailingAction: {}
            )
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            MinimalDoubleButton(
                leadingTitle: "Loading",
                leadingIsLoading: true,
                leadingAction: {},
                trailingTitle: "Loading",
                trailingIsLoading: true,
                trailingAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")

            MinimalDoubleButton(
                leadingTitle: "Leading",
                leadingLeadingView: {
                    Icon.placeholder
                },
                leadingAction: {},
                trailingTitle: "Trailing",
                trailingLeadingView: {
                    Icon.placeholder
                },
                trailingAction: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("With Icon")
        }
        .padding()
    }
}
