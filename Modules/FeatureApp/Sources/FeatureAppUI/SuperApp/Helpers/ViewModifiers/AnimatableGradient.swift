// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

// TODO: Move this to a more appropriate module perhaps, it may be useful for other views as well.

/// A linear animated gradient view modifier
struct AnimatableLinearGradient: ViewModifier, AnimatableModifier {
    let from: [Color]
    let to: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    var percent: CGFloat = 0.0

    var animatableData: CGFloat {
        get { percent }
        set { percent = newValue }
    }

    func body(content: Content) -> some View {
        var gradientColors: [Color] = []
        for i in 0..<from.count {
            let fromColor = UIColor(from[i])
            let toColor = UIColor(to[i])
            gradientColors.append(colorMixing(from: fromColor, to: toColor, percent: percent))
        }
        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// A simple color mixer
    private func colorMixing(
        from: UIColor,
        to: UIColor,
        percent: CGFloat
    ) -> Color {
        var hueFrom: CGFloat = 0
        var saturationFrom: CGFloat = 0
        var brightnessFrom: CGFloat = 0
        var alphaFrom: CGFloat = 0
        from.getHue(
            &hueFrom,
            saturation: &saturationFrom,
            brightness: &brightnessFrom,
            alpha: &alphaFrom
        )

        var hueTo: CGFloat = 0
        var saturationTo: CGFloat = 0
        var brightnessTo: CGFloat = 0
        var alphaTo: CGFloat = 0
        to.getHue(
            &hueTo,
            saturation: &saturationTo,
            brightness: &brightnessTo,
            alpha: &alphaTo
        )

        let hue = hueFrom + (hueTo - hueFrom) * percent
        let bri = brightnessFrom + (brightnessTo - brightnessFrom) * percent
        let sat = saturationFrom + (saturationTo - saturationFrom) * percent
        let alpha = alphaFrom + (alphaTo - alphaFrom) * percent
        let uiColor = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: alpha)
        return Color(uiColor)
    }
}

extension View {

    /// Provides an animated LinearGradient
    /// - Parameters:
    ///   - fromColors: The colors that the animation will begin from
    ///   - toColors: The colors that the animation will end to
    ///   - startPoint: A `UnitPoint` that indicates the start position of the gradient
    ///   - endPoint: A `UnitPoint` that indicates the end position of the gradient
    ///   - percent: A `CGFloat` for the percentage of the color blending (animated).
    ///   At `0.0` value the `fromColors` are displayed at `1.0` the `toColors`
    /// - Returns: some View
    func animatableLinearGradient(
        fromColors: [Color],
        toColors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint,
        percent: CGFloat
    ) -> some View {
        modifier(
            AnimatableLinearGradient(
                from: fromColors,
                to: toColors,
                startPoint: startPoint,
                endPoint: endPoint,
                percent: percent
            )
        )
    }
}
