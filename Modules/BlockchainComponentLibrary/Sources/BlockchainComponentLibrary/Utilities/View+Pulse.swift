// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    /// Adds a circular pulsing animation behind the view to draw the user's eye.
    /// - Parameters:
    ///   - enabled: Whether the animation is enabled or not.
    ///   - inset: Optional inset padding
    @ViewBuilder public func pulse(
        enabled: Bool = true,
        inset: CGFloat = 0
    ) -> some View {
        self
            .if(enabled) {
                $0.background(
                    PulseView()
                        .padding(inset)
                )
            }
    }
}

private struct PulseView: View {
    private let animation = Animation
        .easeInOut(duration: 2.0)
        .repeatForever(autoreverses: false)

    @State var isAnimating: Bool = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                circle(in: proxy)
                    .animation(animation.delay(0.0), value: isAnimating)

                circle(in: proxy)
                    .animation(animation.delay(0.4), value: isAnimating)

                circle(in: proxy)
                    .animation(animation.delay(0.8), value: isAnimating)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                isAnimating = true
            }
        }
    }

    @ViewBuilder func circle(in proxy: GeometryProxy) -> some View {
        Circle()
            .fill(Color.semantic.primary)
            .frame(
                width: 0.8 * proxy.size.width,
                height: 0.8 * proxy.size.height
            )
            .opacity(isAnimating ? 0.0 : 0.4)
            .scaleEffect(isAnimating ? 3.25 : 1.0)
    }
}

struct ViewPulse_Previews: PreviewProvider {
    static var previews: some View {
        Toggle("Toggle", isOn: .constant(false))
            .background(
                Circle()
                    .fill(Color.semantic.background)
                    .frame(width: 40, height: 40)
            )
            .pulse(inset: 8)

        Circle()
            .fill(Color.semantic.primary)
            .frame(width: 80, height: 80)
            .pulse()
    }
}
