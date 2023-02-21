// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

// MARK: Public semantic colors

extension Color {

    public static let semantic: WalletSemantic.Type = WalletSemantic.self

    /// Colors from the Figma Component Library.
    ///
    ///
    /// # Usage:
    ///
    /// `Text("Hello World!").foregroundColor(.semantic.title)`
    ///
    /// - Version: 1.0.1
    ///
    /// # Figma
    ///
    ///  [Colors](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=352%3A8610)
    public enum WalletSemantic {

        public static let title = Color(
            light: .palette.grey900,
            dark: .palette.white
        )

        public static let body = Color(
            light: .palette.grey800,
            dark: .palette.dark200
        )

        public static let text = Color(
            light: .palette.grey600,
            dark: .palette.dark200
        )

        public static let overlay = Color(
            light: .palette.overlay600,
            dark: .palette.overlay600
        )

        public static let muted = Color(
            light: .palette.grey400,
            dark: .palette.dark400
        )

        public static let dark = Color(
            light: .palette.grey300,
            dark: .palette.dark700
        )

        public static let medium = Color(
            light: .palette.grey100,
            dark: .palette.dark600
        )

        public static let light = Color(
            light: .palette.grey000,
            dark: .palette.dark800
        )

        public static let background = Color(
            light: .palette.white,
            dark: .palette.dark900
        )

        public static let dsaBackground = Color.semantic.light

        public static let dsaContentBackground = Color(
            light: .palette.white,
            dark: .palette.dark900
        )

        public static let primary = Color(
            light: .palette.blue600,
            dark: .palette.blue400
        )

        public static let primaryMuted = Color(
            light: .palette.blue400,
            dark: .palette.blue400
        )

        public static let success = Color(
            light: .palette.green700,
            dark: .palette.green400
        )

        public static let warning = Color(
            light: .palette.orange600,
            dark: .palette.orange400
        )

        public static let error = Color(
            light: .palette.red600,
            dark: .palette.red400
        )

        public static let defi = Color(
            light: .palette.purple,
            dark: .palette.purple
        )

        public static let fadedBackground: Color = .palette.grey600.opacity(0.6)

        public static let darkBG: Color = .palette.dark900
        public static let blueBG: Color = .palette.blue000
        public static let greenBG: Color = .palette.green100
        public static let orangeBG: Color = .palette.orange100
        public static let redBG: Color = .palette.red100
        public static let fiatGreen: Color = .init(hex: "#00B26B")

        public static let gold: Color = .palette.gold
        public static let silver: Color = .palette.silver
        public static let pink: Color = .palette.pink600

        public static let pinkHighlight: Color = .palette.pink600
    }
}

// MARK: Internal palette for component library usage

extension Color {

    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self = Color(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
            }
        )
        #else
        self = Color(
            NSColor(name: nil) { appearance in
                switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
                case .some(.darkAqua):
                    return NSColor(dark)
                default:
                    return NSColor(light)
                }
            }
        )
        #endif
    }

    static let palette: Palette.Type = Palette.self

    enum Palette {
        // base
        static let white: Color = Asset.white.color()
        static let black: Color = Asset.black.color()
        // dark
        static let dark000: Color = Asset.dark000.color()
        static let dark100: Color = Asset.dark100.color()
        static let dark200: Color = Asset.dark200.color()
        static let dark300: Color = Asset.dark300.color()
        static let dark400: Color = Asset.dark400.color()
        static let dark500: Color = Asset.dark500.color()
        static let dark600: Color = Asset.dark600.color()
        static let dark700: Color = Asset.dark700.color()
        static let dark800: Color = Asset.dark800.color()
        static let dark900: Color = Asset.dark900.color()
        // grey
        static let grey000: Color = Asset.grey000.color()
        static let grey100: Color = Asset.grey100.color()
        static let grey200: Color = Asset.grey200.color()
        static let grey300: Color = Asset.grey300.color()
        static let grey400: Color = Asset.grey400.color()
        static let grey500: Color = Asset.grey500.color()
        static let grey600: Color = Asset.grey600.color()
        static let grey700: Color = Asset.grey700.color()
        static let grey800: Color = Asset.grey800.color()
        static let grey900: Color = Asset.grey900.color()
        // overlay
        static let overlay400: Color = Asset.overlay400.color()
        static let overlay600: Color = Asset.overlay600.color()
        static let overlay800: Color = Asset.overlay800.color()
        // blue
        static let blue000: Color = Asset.blue000.color()
        static let blue400: Color = Asset.blue400.color()
        static let blue600: Color = Asset.blue600.color()
        static let blue700: Color = Asset.blue700.color()
        // green
        static let green100: Color = Asset.green100.color()
        static let green400: Color = Asset.green400.color()
        static let green500: Color = Asset.green500.color()
        static let green600: Color = Asset.green600.color()
        static let green700: Color = Asset.green700.color()
        static let green800: Color = Asset.green800.color()
        static let green900: Color = Asset.green900.color()

        // red
        static let red000: Color = Asset.red000.color()
        static let red100: Color = Asset.red100.color()
        static let red400: Color = Asset.red400.color()
        static let red600: Color = Asset.red600.color()
        static let red700: Color = Asset.red700.color()
        static let red900: Color = Asset.red900.color()
        // orange
        static let orange100: Color = Asset.orange100.color()
        static let orange400: Color = Asset.orange400.color()
        static let orange600: Color = Asset.orange600.color()
        // tiers
        static let silver: Color = Asset.silver.color()
        static let gold: Color = Asset.gold.color()

        // purple
        static let purple: Color = Asset.purple.color()

        // pink
        static let pink600: Color = Asset.pink600.color()
        static let pink700: Color = Asset.pink700.color()
    }
}

// MARK: Private Asset Palette from Textures.xcassets

extension Color {

    private enum Asset: String {
        // base
        case white
        case black
        // dark
        case dark000
        case dark100
        case dark200
        case dark300
        case dark400
        case dark500
        case dark600
        case dark700
        case dark800
        case dark900
        // grey
        case grey000
        case grey100
        case grey200
        case grey300
        case grey400
        case grey500
        case grey600
        case grey700
        case grey800
        case grey900
        // overlay
        case overlay400
        case overlay600
        case overlay800
        // blue
        case blue000
        case blue400
        case blue600
        case blue700
        // green
        case green100
        case green400
        case green500
        case green600
        case green700
        case green800
        case green900
        // red
        case red000
        case red100
        case red400
        case red600
        case red700
        case red900
        // orange
        case orange100
        case orange400
        case orange600
        // tiers
        case silver
        case gold

        case purple

        case pink600
        case pink700

        func color() -> SwiftUI.Color {
            SwiftUI.Color(rawValue, bundle: Bundle.componentLibrary)
        }
    }
}

struct Colors_Previews: PreviewProvider {

    struct ColorMap: Identifiable {
        let color: Color
        let name: String
        var id: String { name }
    }

    static let allColors: [ColorMap] = [
        ColorMap(color: .semantic.title, name: "title"),
        ColorMap(color: .semantic.body, name: "body"),
        ColorMap(color: .semantic.overlay, name: "overlay"),
        ColorMap(color: .semantic.muted, name: "muted"),
        ColorMap(color: .semantic.dark, name: "dark"),
        ColorMap(color: .semantic.medium, name: "medium"),
        ColorMap(color: .semantic.light, name: "light"),
        ColorMap(color: .semantic.background, name: "background"),
        ColorMap(color: .semantic.primary, name: "primary"),
        ColorMap(color: .semantic.success, name: "success"),
        ColorMap(color: .semantic.warning, name: "warning"),
        ColorMap(color: .semantic.error, name: "error"),
        ColorMap(color: .semantic.blueBG, name: "blueBG"),
        ColorMap(color: .semantic.greenBG, name: "greenBG"),
        ColorMap(color: .semantic.orangeBG, name: "orangeBG"),
        ColorMap(color: .semantic.redBG, name: "redBG"),
        ColorMap(color: .semantic.defi, name: "defi")
    ]

    static var previews: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                ForEach(allColors) {
                    swatch(color: $0.color, name: $0.name)
                }
            }
            .padding(12)
        }
    }

    @ViewBuilder static func swatch(color: Color, name: String) -> some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 120)
            Text(name)
                .lineLimit(1)
                .padding()
                .truncationMode(.tail)
                .foregroundColor(.semantic.title)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.semantic.overlay, lineWidth: 0.5)
        )
    }
}

extension Color {

    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xf) * 17, (int & 0xf) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xff, int & 0xff)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
