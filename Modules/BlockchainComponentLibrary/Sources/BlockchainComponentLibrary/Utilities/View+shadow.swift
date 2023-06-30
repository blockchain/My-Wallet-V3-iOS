import SwiftUI

extension View {

    @warn_unqualified_access public func backgroundWithShadow(
        _ edges: Edge.Set,
        fill: Color = .semantic.background,
        color shadow: Color = .semantic.dark.opacity(0.5),
        radius: CGFloat = 8
    ) -> some View {
        background(
            Rectangle()
                .fill(fill)
                .shadow(color: shadow, radius: radius)
        )
        .mask(Rectangle().padding(edges, -20))
    }

    @warn_unqualified_access public func overlayWithShadow(
        _ alignment: Alignment,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom,
        color shadow: Color = .semantic.dark.opacity(0.5),
        radius: CGFloat = 8
    ) -> some View {
        overlay(
            LinearGradient(colors: [shadow, .clear], startPoint: startPoint, endPoint: endPoint)
                .frame(maxWidth: .infinity, maxHeight: radius)
                .allowsHitTesting(false),
            alignment: alignment
        )
    }

    public var backgroundWithWhiteShadow: some View {
        background(
            Rectangle()
                .fill(Color.semantic.background)
                .shadow(color: Color.semantic.background, radius: 3, x: 0, y: -10)
        )
    }

    public var backgroundWithLightShadow: some View {
        background(
            Rectangle()
                .fill(Color.semantic.light)
                .shadow(color: Color.semantic.light, radius: 3, x: 0, y: -10)
        )
    }
}
