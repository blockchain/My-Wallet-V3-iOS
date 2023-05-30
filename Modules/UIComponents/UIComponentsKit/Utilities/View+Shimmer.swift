// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    /// Adds a shimmering gradient effect to the view.
    ///
    /// Currently built to match `ShimmeringView` in `PlatformUIKit`
    /// - Parameters:
    ///   - enabled: If true, shows the shimmering view. If false, shows the original view content.
    ///   - cornerRadius: Corner radius for shimmering overlay.
    @ViewBuilder public func shimmer(
        enabled: Bool = true,
        cornerRadius: CGFloat = 4.0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> some View {
        if enabled {
            modifier(
                Shimmer(
                    cornerRadius: cornerRadius,
                    width: width,
                    height: height
                )
            )
        } else {
            self
        }
    }
}

private struct Shimmer: ViewModifier {
    let cornerRadius: CGFloat
    let width: CGFloat?
    let height: CGFloat?

    @State private var startPoint = UnitPoint(x: -1.0, y: 2.0) // 1x before bottomLeading
    @State private var endPoint: UnitPoint = .bottomLeading

    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .hidden()
            .overlay(
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: .semantic.light, location: 0.0),
                            .init(color: .semantic.dark, location: 0.5),
                            .init(color: .semantic.light, location: 1.0)
                        ]
                    ),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .cornerRadius(cornerRadius)
                .animation(.linear(duration: 3.0).repeatForever(autoreverses: false))
                .onAppear {
                    startPoint = .topTrailing
                    endPoint = UnitPoint(x: 2.0, y: -1.0) // 1x past topTrailing
                }
            )
    }
}

struct Shimmer_Previews: PreviewProvider {

    static var previews: some View {
        Text(" ") // A space is used to get the correct height for the shimmer
            .shimmer(width: 100)
            .previewLayout(.sizeThatFits)
    }
}
