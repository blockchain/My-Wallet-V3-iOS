// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct PillButtonStyle: ButtonStyle {

    public struct ColorSet {
        let foreground: Color
        let background: Color
        let border: Color

        public init(
            foreground: Color,
            background: Color,
            border: Color
        ) {
            self.foreground = foreground
            self.background = background
            self.border = border
        }
    }

    public struct ColorCombination {
        let enabled: ColorSet
        let pressed: ColorSet
        let disabled: ColorSet
        let progressViewRail: Color
        let progressViewTrack: Color

        public init(
            enabled: ColorSet,
            pressed: ColorSet,
            disabled: ColorSet,
            progressViewRail: Color,
            progressViewTrack: Color
        ) {
            self.enabled = enabled
            self.pressed = pressed
            self.disabled = disabled
            self.progressViewRail = progressViewRail
            self.progressViewTrack = progressViewTrack
        }
    }

    let isLoading: Bool
    let isEnabled: Bool
    let size: PillButtonSize
    let isRounded: Bool
    let colorCombination: ColorCombination

    private var cornerRadius: CGFloat {
        isRounded ? size.borderRadius : 0
    }

    init(
        isLoading: Bool,
        isEnabled: Bool,
        size: PillButtonSize = .standard,
        isRounded: Bool = true,
        colorCombination: ColorCombination
    ) {
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.size = size
        self.isRounded = isRounded
        self.colorCombination = colorCombination
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(
                        BlockchainCircularProgressViewStyle(
                            stroke: colorCombination.progressViewRail,
                            background: colorCombination.progressViewTrack
                        )
                    )
                    .frame(width: size.minHeight / 2, height: size.minHeight / 2)
            } else {
                configuration
                    .label
                    .typography(size.typograhy)
            }
        }
        .accentColor(colorSet(for: configuration).foreground)
        .foregroundColor(colorSet(for: configuration).foreground)
        .frame(maxWidth: size.maxWidth, minHeight: size.minHeight)
        .padding(size.padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(colorSet(for: configuration).background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(colorSet(for: configuration).border)
        )
        .contentShape(Rectangle())
    }

    private func colorSet(for configuration: Configuration) -> ColorSet {
        if configuration.isPressed {
            colorCombination.pressed
        } else if isEnabled {
            colorCombination.enabled
        } else {
            colorCombination.disabled
        }
    }
}

// MARK: Button Size Environment Extension

private struct PillButtonSizeEnvironmentKey: EnvironmentKey {

    static var defaultValue: PillButtonSize = .standard
}

extension EnvironmentValues {

    var pillButtonSize: PillButtonSize {
        get { self[PillButtonSizeEnvironmentKey.self] }
        set { self[PillButtonSizeEnvironmentKey.self] = newValue }
    }
}

extension View {

    public func pillButtonSize(_ size: PillButtonSize) -> some View {
        environment(\.pillButtonSize, size)
    }
}

// MARK: Button ColorSet Environment Extension

private struct ColorCombinationEnvironmentKey: EnvironmentKey {

    static var defaultValue: PillButtonStyle.ColorCombination = .primary
}

extension EnvironmentValues {

    var colorCombination: PillButtonStyle.ColorCombination {
        get { self[ColorCombinationEnvironmentKey.self] }
        set { self[ColorCombinationEnvironmentKey.self] = newValue }
    }
}

extension View {

    public func colorCombination(
        _ colorCombination: PillButtonStyle.ColorCombination
    ) -> some View {
        environment(\.colorCombination, colorCombination)
    }
}
