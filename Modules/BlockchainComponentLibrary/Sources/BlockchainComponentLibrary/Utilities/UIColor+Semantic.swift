// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import Extensions
import UIKit

extension UIColor {

    public static let semantic: WalletSemantic.Type = WalletSemantic.self

    public enum WalletSemantic {

        public static let title = UIColor(
            light: .palette.grey900,
            dark: .palette.white
        )

        public static let body = UIColor(
            light: .palette.grey800,
            dark: .palette.dark200
        )

        public static let text = UIColor(
            light: .palette.grey600,
            dark: .palette.dark200
        )

        public static let overlay = UIColor(
            light: .palette.overlay600,
            dark: .palette.overlay600
        )

        public static let muted = UIColor(
            light: .palette.grey400,
            dark: .palette.dark400
        )

        public static let dark = UIColor(
            light: .palette.grey300,
            dark: .palette.dark700
        )

        public static let medium = UIColor(
            light: .palette.grey100,
            dark: .palette.dark600
        )

        public static let light = UIColor(
            light: .palette.grey000,
            dark: .palette.dark900
        )

        public static let ultraLight = UIColor(
            light: .palette.grey00,
            dark: .palette.dark800
        )

        public static let background = UIColor(
            light: .palette.white,
            dark: .palette.dark800
        )

        public static let lightBackground = UIColor(
            light: .palette.grey000,
            dark: .palette.white
        )

        public static let border = light

        public static let dsaBackground = Color.semantic.light

        public static let dsaContentBackground = UIColor(
            light: .palette.white,
            dark: .palette.dark900
        )

        public static let primary = UIColor(
            light: .palette.blue600,
            dark: .palette.blue400
        )

        public static let primaryUltraLight = UIColor(
            light: .palette.blue000,
            dark: .palette.blue200
        )

        public static let primaryMuted = UIColor(
            light: .palette.blue400,
            dark: .palette.blue400
        )

        public static let success = UIColor(
            light: .palette.green700,
            dark: .palette.green400
        )

        public static let warning = UIColor(
            light: .palette.orange600,
            dark: .palette.orange400
        )

        public static let error = UIColor(
            light: .palette.red600,
            dark: .palette.red400
        )

        public static let defi = UIColor(
            light: .palette.purple,
            dark: .palette.purple
        )
    }
}

#endif
