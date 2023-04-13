// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CasePaths
import Extensions
import SwiftUI

extension View {

    /// Apply a foreground media to the view
    public func foregroundTexture(_ url: URL) -> some View {
        modifier(TextureModifier.foreground(url.texture))
    }

    /// Apply a foreground color to the view
    public func foregroundTexture(_ color: Color) -> some View {
        modifier(TextureModifier.foreground(color.texture))
    }

    /// Apply a foreground gradient to the view
    /// this will mask the gradient with the contents of the view
    public func foregroundTexture(
        linear gradient: Gradient,
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> some View {
        modifier(
            TextureModifier.foreground(gradient.linearTexture(start: startPoint, end: endPoint))
        )
    }

    /// Apply a foreground texture to the view
    public func foregroundTexture(_ texture: Texture) -> some View {
        modifier(TextureModifier.foreground(texture))
    }

    /// Apply an optional foreground texture to the view
    /// if no texture is available the original view will be left untouched
    @ViewBuilder public func foregroundTexture(_ texture: Texture?) -> some View {
        modifier(texture.map(TextureModifier.foreground) ?? .none)
    }

    /// Apply a background media to the view
    public func backgroundTexture(_ url: URL) -> some View {
        modifier(TextureModifier.background(url.texture))
    }

    /// Apply a background color to the view
    public func backgroundTexture(_ color: Color) -> some View {
        modifier(TextureModifier.background(color.texture))
    }

    /// Apply a background gradient to the view
    public func backgroundTexture(
        linear gradient: Gradient,
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> some View {
        modifier(
            TextureModifier.background(gradient.linearTexture(start: startPoint, end: endPoint))
        )
    }

    /// Apply a background texture to the view
    public func backgroundTexture(_ texture: Texture) -> some View {
        modifier(TextureModifier.background(texture))
    }

    /// Apply a background color to the view
    /// if no texture is available the original view will be left untouched
    @ViewBuilder public func backgroundTexture(_ texture: Texture?) -> some View {
        modifier(texture.map(TextureModifier.background) ?? .none)
    }
}

public struct Texture: Codable, Hashable {

    public var color: Color?
    public var gradient: Gradient?
    public var media: Media?

    public init(
        color: Texture.Color? = nil,
        gradient: Texture.Gradient? = nil,
        media: Texture.Media? = nil
    ) {
        self.color = color
        self.gradient = gradient
        self.media = media
    }
}

extension Texture {

    public enum Color: Codable, Hashable {
        case rgb(r: Double, g: Double, b: Double, a: Double)
        case hsb(h: Double, s: Double, b: Double, a: Double)
    }

    public struct Gradient: Codable, Hashable {

        public struct Stop: Codable, Hashable {

            public var color: Color
            public var location: CGFloat

            public init(color: Texture.Color, location: CGFloat) {
                self.color = color
                self.location = location
            }
        }

        public struct Linear: Codable, Hashable {

            public var start: [CGFloat]
            public var end: [CGFloat]

            public init(start: [CGFloat], end: [CGFloat]) {
                self.start = start
                self.end = end
            }
        }

        public var stops: [Stop]
        public var linear: Linear?

        public init(
            stops: [Texture.Gradient.Stop],
            linear: Texture.Gradient.Linear? = nil
        ) {
            self.stops = stops
            self.linear = linear
        }
    }

    public struct Media: Codable, Hashable {

        public struct Resizing: Codable, Hashable {
            let mode: MediaResizingMode
        }

        public let url: URL
        public let resizing: Resizing?

        public init(url: URL, resizing: Resizing? = nil) {
            self.url = url
            self.resizing = resizing
        }
    }
}

extension Texture.Color {

    public var swiftUI: SwiftUI.Color { .init(self) }

    public enum Key: String, CodingKey {
        case rgb
        case hsb
    }

    private typealias Case = CasePath<Texture.Color, (Double, Double, Double, Double)>

    private static var __allCases: [Key: Case] = [
        Key.rgb: /Texture.Color.rgb,
        Key.hsb: /Texture.Color.hsb
    ]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        for (key, casePath) in Self.__allCases {
            do {
                var nested = try container.nestedUnkeyedContainer(forKey: key)
                self = try casePath.embed(
                    (
                        nested.decode(Double.self),
                        nested.decode(Double.self),
                        nested.decode(Double.self),
                        nested.decode(Double.self)
                    )
                )
                return
            } catch {
                continue
            }
        }
        throw DecodingError.valueNotFound(
            Self.self,
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "No color was found at codingPath '\(decoder.codingPath)'"
            )
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        for (key, casePath) in Self.__allCases {
            do {
                if let o = casePath.extract(from: self) {
                    var nested = container.nestedUnkeyedContainer(forKey: key)
                    try nested.encode(o.0)
                    try nested.encode(o.1)
                    try nested.encode(o.2)
                    try nested.encode(o.3)
                    return
                }
             } catch {
                 continue
             }
        }
    }
}

extension Texture: View {

    public var body: some View {
        if let color {
            SwiftUI.Color(color)
        } else if let gradient, let linearGradient = LinearGradient(gradient) {
            linearGradient
        } else if let media {
            AsyncMedia(url: media.url, placeholder: EmptyView.init)
        }
    }
}

enum TextureModifier: ViewModifier {

    case foreground(Texture)
    case background(Texture)
    case none

    func body(content: Content) -> some View {
        switch self {
        case .none:
            content
        case .foreground(let texture):
            if let media = texture.media {
                let view = content
                    .foregroundColor(.clear)
                    .overlay(
                        AsyncMedia(url: media.url, placeholder: EmptyView.init)
                            .aspectRatio(contentMode: .fit)
                            .mask(content)
                    )
                if let resizingMode = media.resizing?.mode {
                    view.resizingMode(resizingMode)
                } else {
                    view
                }
            } else if let gradient = texture.gradient, let linearGradient = LinearGradient(gradient) {
                content
                    .foregroundColor(.clear)
                    .overlay(linearGradient.mask(content))
            } else if let color = texture.color {
                content.foregroundColor(.init(color))
            } else {
                content
            }
        case .background(let texture):
            if let media = texture.media {
                content.background(
                    ZStack(alignment: .top) {
                        if let gradient = texture.gradient.flatMap(LinearGradient.init) {
                            gradient
                        } else if let color = texture.color {
                            color.swiftUI
                        }
                        let view = AsyncMedia(url: media.url, placeholder: EmptyView.init)
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0.pt, maxWidth: 100.vw, minHeight: 0.pt, maxHeight: 100.vh)
                            .transition(.opacity.combined(with: .scale))
                        if let resizingMode = media.resizing?.mode {
                            view.resizingMode(resizingMode)
                        } else {
                            view
                        }
                    }
                    .ignoresSafeArea(.all, edges: .all)
                )
            } else if let gradient = texture.gradient, let linearGradient = LinearGradient(gradient) {
                content.background(linearGradient)
            } else if let color = texture.color {
                content.background(SwiftUI.Color(color))
            } else {
                content
            }
        }
    }
}

extension Color {

    #if canImport(UIKit)
    private typealias Native = UIColor
    #elseif canImport(AppKit)
    private typealias Native = NSColor
    #endif

    private var hsba: (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
        var (h, s, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        #if canImport(UIKit)
        guard Native(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return (0, 0, 0, 0)
        }
        #elseif canImport(AppKit)
        Native(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        #endif
        return (h.d, s.d, b.d, a.d)
    }

    private var rgba: (red: Double, green: Double, blue: Double, alpha: Double) {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        #if canImport(UIKit)
        guard Native(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return (0, 0, 0, 0)
        }
        #elseif canImport(AppKit)
        Native(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return (r.d, g.d, b.d, a.d)
    }

    public var rgbTexture: Texture {
        let (r, g, b, a) = rgba
        return .init(color: .rgb(r: r, g: g, b: b, a: a))
    }

    public var hsbTexture: Texture {
        let (h, s, b, a) = hsba
        return .init(color: .hsb(h: h, s: s, b: b, a: a))
    }

    public var texture: Texture { hsbTexture }

    public init?(_ texture: Texture, colorSpace: Color.RGBColorSpace = .sRGB) {
        if let color = texture.color {
            self.init(color, colorSpace: colorSpace)
        } else if let color = texture.gradient?.stops.first?.color {
            self.init(color, colorSpace: colorSpace)
        } else {
            return nil
        }
    }

    public init(_ color: Texture.Color, colorSpace: Color.RGBColorSpace = .sRGB) {
        switch color {
        case .hsb(let h, let s, let b, let a):
            self.init(hue: h, saturation: s, brightness: b, opacity: a)
        case .rgb(let r, let g, let b, let a):
            self.init(colorSpace, red: r, green: g, blue: b, opacity: a)
        }
    }
}

extension Gradient {

    public func linearTexture(start: UnitPoint, end: UnitPoint) -> Texture {
        .init(
            gradient: .init(
                stops: stops.map { stop in
                    Texture.Gradient.Stop(
                        color: stop.color.texture.color!,
                        location: stop.location
                    )
                },
                linear: .init(start: [start.x, start.y], end: [end.x, end.y])
            )
        )
    }

    public init?(_ texture: Texture, colorSpace: Color.RGBColorSpace = .sRGB) {
        if let gradient = texture.gradient {
            self.init(gradient, colorSpace: colorSpace)
        } else if let color = texture.color {
            self.init(
                stops: [
                    Stop(color: Color(color, colorSpace: colorSpace), location: 0),
                    Stop(color: Color(color, colorSpace: colorSpace), location: 1)
                ]
            )
        } else {
            return nil
        }
    }

    public init(_ gradient: Texture.Gradient, colorSpace: Color.RGBColorSpace = .sRGB) {
        self.init(
            stops: gradient.stops.map { stop in
                Stop(
                    color: Color(stop.color, colorSpace: colorSpace),
                    location: stop.location
                )
            }
        )
    }
}

extension LinearGradient {

    public init?(_ gradient: Texture.Gradient) {
        guard
            let linear = gradient.linear,
            let start = UnitPoint(linear.start),
            let end = UnitPoint(linear.end)
        else {
            return nil
        }
        self.init(gradient: Gradient(gradient), startPoint: start, endPoint: end)
    }
}

extension UnitPoint {

    fileprivate init?(_ xy: [CGFloat]) {
        guard xy.count == 2 else { return nil }
        self.init(x: xy[0], y: xy[1])
    }
}

extension URL {

    public var texture: Texture {
        Texture(media: Texture.Media(url: self))
    }
}

#if DEBUG
struct Texture_Previews: PreviewProvider {

    static let allTypography: [Typography] = [
        .display,
        .title1,
        .title2,
        .title3,
        .subheading,
        .bodyMono,
        .body1,
        .body2,
        .paragraphMono,
        .paragraph1,
        .paragraph2,
        .caption1,
        .caption2,
        .overline
    ]

    static var previews: some View {
        ScrollView {
            VStack {
                Text("Globe")
                    .typography(.display)
                    .foregroundTexture(.semantic.light.opacity(0.5))
                    .backgroundTexture(
                        URL(string: "https://file-examples.com/storage/fe52cb0c4862dc676a1b341/2017/04/file_example_MP4_480_1_5MG.mp4")!
                    )
                    .padding(20.pt)
                    Rectangle()
                        .frame(height: 100)
                        .foregroundTexture(
                            linear: Gradient(
                                colors: [
                                    .semantic.warning,
                                    .semantic.primary
                                ]
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            Text("warning -> primary")
                                .padding()
                                .typography(.display)
                                .scaledToFit()
                                .minimumScaleFactor(0.5)
                                .foregroundColor(.white)
                        )
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(.clear)
                        .backgroundTexture(.semantic.greenBG)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            Text("error -> gold")
                                .padding()
                                .typography(.display)
                                .foregroundTexture(
                                    linear: Gradient(
                                        colors: [
                                            .semantic.error,
                                            .semantic.gold
                                        ]
                                    )
                                )
                        )
                    ForEach(allTypography, id: \.self) { typography in
                        Text("The quick brown fox jumps over the lazy dog")
                            .frame(maxWidth: .infinity)
                            .typography(typography)
                            .foregroundTexture(
                                linear: Gradient(
                                    colors: [
                                        .semantic.warning,
                                        .semantic.primaryMuted,
                                        .semantic.primary,
                                        .semantic.success,
                                        .semantic.error,
                                        .semantic.gold
                                    ]
                                )
                            )
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
            }
            .padding()
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
#endif
