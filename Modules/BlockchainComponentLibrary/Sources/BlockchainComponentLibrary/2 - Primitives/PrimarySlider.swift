// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A horizontal slider used for picking from a range of values.
///
///     PrimarySlider(
///         value: $value,
///         in: 0...10,
///         step: 1
///     )
///
/// # Figma
///
/// [Slider](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=6%3A1469)
public struct PrimarySlider<Value: BinaryFloatingPoint>: View
    where Value.Stride: BinaryFloatingPoint
{
    @Binding var value: Value
    let bounds: ClosedRange<Value>
    let step: Value.Stride?

    /// Create a horizontal slider
    /// - Parameters:
    ///   - value: Binding for the current position of the thumb on the slider
    ///   - bounds: Lower and upper limits for the slider
    ///   - step: Optional step for locking the slider to certain increments.
    public init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value>,
        step: Value.Stride? = nil
    ) {
        _value = value
        self.bounds = bounds
        self.step = step
    }

    public var body: some View {
        #if canImport(UIKit)
        SliderRepresentable(
            value: $value,
            bounds: bounds,
            step: step
        )
        #else
        if let step {
            Slider(
                value: $value,
                in: bounds,
                step: step
            )
        } else {
            Slider(
                value: $value,
                in: bounds
            )
        }
        #endif
    }
}

#if canImport(UIKit)

private struct SliderRepresentable<Value: BinaryFloatingPoint>: UIViewRepresentable
    where Value.Stride: BinaryFloatingPoint
{
    @Binding var value: Value
    let bounds: ClosedRange<Value>
    let step: Value.Stride?

    func makeCoordinator() -> Coordinator {
        Coordinator { slider in
            if let step {
                let newValue = round(slider.value / Float(step)) * Float(step)
                value = Value(newValue)
                slider.value = newValue
            } else {
                value = Value(slider.value)
            }
        }
    }

    func makeUIView(context: Context) -> UISlider {
        let view = CustomSlider()
        view.minimumTrackTintColor = UIColor(.semantic.primary)
        view.maximumTrackTintColor = UIColor(.semantic.medium)
        view.addTarget(context.coordinator, action: #selector(Coordinator.valueDidChange(sender:)), for: .valueChanged)
        return view
    }

    func updateUIView(_ view: UISlider, context: Context) {
        let colorScheme = context.environment.colorScheme
        view.setThumbImage(thumbImage(for: colorScheme), for: .normal)
        view.minimumValue = Float(bounds.lowerBound)
        view.maximumValue = Float(bounds.upperBound)
        view.value = Float(value)
    }

    private func thumbBackgroundColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            .palette.dark500
        default:
            .palette.white
        }
    }

    private func thumbBorderColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            .palette.dark900
        default:
            .palette.grey000
        }
    }

    private func firstShadow(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            .black.opacity(0.12)
        default:
            .black.opacity(0.06)
        }
    }

    private func secondShadow(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            .black.opacity(0.12)
        default:
            .black.opacity(0.15)
        }
    }

    private func thumbImage(for colorScheme: ColorScheme) -> UIImage {
        let ellipseDiameter: CGFloat = 28
        let shadowSize: CGFloat = 10
        let totalSize = ellipseDiameter + shadowSize * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalSize, height: totalSize))
        let image = renderer.image { context in
            let ellipseBounds = context.format.bounds.insetBy(dx: shadowSize, dy: shadowSize)
            UIColor(thumbBorderColor(for: colorScheme)).setFill()
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 3),
                blur: 1,
                color: firstShadow(for: colorScheme).cgColor
            )
            context.cgContext.fillEllipse(in: ellipseBounds)

            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: 3),
                blur: 8,
                color: secondShadow(for: colorScheme).cgColor
            )
            context.cgContext.fillEllipse(in: ellipseBounds)

            context.cgContext.setShadow(offset: .zero, blur: 0, color: nil)
            UIColor(thumbBackgroundColor(for: colorScheme)).setFill()
            context.cgContext.fillEllipse(in: ellipseBounds.insetBy(dx: 1, dy: 1))
        }
        return image
    }

    class Coordinator: NSObject {
        let valueChanged: (UISlider) -> Void

        init(valueChanged: @escaping (UISlider) -> Void) {
            self.valueChanged = valueChanged
        }

        @objc func valueDidChange(sender: UISlider) {
            valueChanged(sender)
        }
    }
}

private class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        return rect.insetBy(dx: 16, dy: 1)
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        // Outset track rect so the thumb goes all the way to the edge
        super.thumbRect(forBounds: bounds, trackRect: rect.insetBy(dx: -16, dy: 0), value: value)
    }
}

#endif

struct PrimarySlider_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
            .background(Color.semantic.background)
            .previewLayout(.sizeThatFits)

        PreviewContainer()
            .background(Color.semantic.background)
            .colorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }

    struct PreviewContainer: View {
        @State var value: Double = 5
        let range: ClosedRange<Double> = 0...10

        var body: some View {
            PrimarySlider(value: $value, in: range)
        }
    }
}
