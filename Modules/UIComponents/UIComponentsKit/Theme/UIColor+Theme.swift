// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

// LEGACY, for UIKit support
extension UIColor {

    // MARK: Grey Fade

    fileprivate static let greyFade800 = UIColor(paletteColor: .greyFade800)
    fileprivate static let greyFade900 = UIColor(paletteColor: .greyFade900)

    // MARK: Grey

    fileprivate static let grey000 = UIColor(paletteColor: .grey000)
    fileprivate static let grey050 = UIColor(paletteColor: .grey050)
    fileprivate static let grey100 = UIColor(paletteColor: .grey100)
    fileprivate static let grey200 = UIColor(paletteColor: .grey200)
    fileprivate static let grey400 = UIColor(paletteColor: .grey400)
    fileprivate static let grey600 = UIColor(paletteColor: .grey600)
    fileprivate static let grey800 = UIColor(paletteColor: .grey800)
    fileprivate static let grey900 = UIColor(paletteColor: .grey900)

    // MARK: Blue

    fileprivate static let blue000 = UIColor(paletteColor: .blue000)
    fileprivate static let blue100 = UIColor(paletteColor: .blue100)
    fileprivate static let blue400 = UIColor(paletteColor: .blue400)
    fileprivate static let blue600 = UIColor(paletteColor: .blue600)
    fileprivate static let blue700 = UIColor(paletteColor: .blue700)
    fileprivate static let blue900 = UIColor(paletteColor: .blue900)

    // MARK: Green

    fileprivate static let green000 = UIColor(paletteColor: .green000)
    fileprivate static let green400 = UIColor(paletteColor: .green400)
    fileprivate static let green500 = UIColor(paletteColor: .green500)
    fileprivate static let green600 = UIColor(paletteColor: .green600)

    // MARK: Red

    fileprivate static let red100 = UIColor(paletteColor: .red100)
    fileprivate static let red400 = UIColor(paletteColor: .red400)
    fileprivate static let red500 = UIColor(paletteColor: .red500)
    fileprivate static let red600 = UIColor(paletteColor: .red600)

    // MARK: Orange

    fileprivate static let orange000 = UIColor(paletteColor: .orange000)
    fileprivate static let orange600 = UIColor(paletteColor: .orange600)
}

// MARK: - Thematic Color Definitions

extension UIColor {

    // MARK: Primary

    public static let primary = blue900
    public static let secondary = blue600
    public static let tertiary = blue400

    public convenience init?(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard clean.count == 6 else {
            return nil
        }
        var rgbValue: UInt64 = 0
        guard Scanner(string: clean).scanHexInt64(&rgbValue) else {
            return nil
        }
        self.init(
            red: CGFloat(rgbValue >> 16) / 255,
            green: CGFloat(rgbValue >> 8 & 0xff) / 255,
            blue: CGFloat(rgbValue & 0xff) / 255,
            alpha: 1
        )
    }

    // MARK: Navigation

    public enum NavigationBar {

        public enum DarkContent {
            public static let background = UIColor.semantic.light // previously, grey000
            public static let title = UIColor.semantic.title // previously, black
            public static let tintColor = UIColor.semantic.title // previously, black
        }

        public enum LightContent {
            public static let background = UIColor.semantic.title // previously, grey900
            public static let title = UIColor.semantic.background // previously, white
            public static let tintColor = UIColor.semantic.background // previously, white
        }

        public enum MutedContent {
            public static let background = UIColor.semantic.light // previously, grey000
            public static let title = UIColor.semantic.primary // previously, primary
            public static let tintColor = UIColor.semantic.primary
            public static let trailingColor = UIColor.semantic.muted // previously, mutedText
        }

        public static let closeButton = grey400
    }

    // MARK: Backgrounds & Borders

    public static let background = grey000
    public static let hightlightedBackground = grey050
    public static let lightBlueBackground = blue000
    public static let darkBlueBackground = blue700
    public static let greyFadeBackground = greyFade800

    public static let lightBorder = grey000
    public static let mediumBorder = grey100
    public static let successBorder = green500
    public static let idleBorder = blue400
    public static let errorBorder = red400

    public static let destructiveBackground = red100
    public static let affirmativeBackground = green000
    public static let defaultBadgeBackground = blue100
    public static let lightBadgeBackground = blue000
    public static let badgeBackgroundWarning = orange000
    public static let darkFadeBackground = greyFade900

    public static let lightShimmering = grey000
    public static let darkShimmering = grey200

    // MARK: Indications

    public static let addressPageIndicator = blue100

    // MARK: Texts

    public static let defaultBadge = blue600
    public static let warningBadge = orange600
    public static let affirmativeBadgeDark = green400
    public static let affirmativeBadgeText = green500

    public static let normalPassword = green600
    public static let strongPassword = blue600
    public static let destructive = red500
    public static let warning = orange600

    public static let darkTitleText = grey900
    public static let titleText = grey800
    public static let descriptionText = grey600
    public static let textFieldPlaceholder = grey400
    public static let textFieldText = grey800
    public static let mutedText = grey400

    public static let positivePrice = green500

    // MARK: Buttons

    public static let destructiveButton = red600
    public static let primaryButton = blue600
    public static let linkableText = blue600

    public static let primaryButtonTitle = white

    // MARK: Currency

    public static let fiat = green500
}
