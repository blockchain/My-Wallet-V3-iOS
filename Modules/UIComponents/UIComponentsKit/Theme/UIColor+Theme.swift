// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

// LEGACY, for UIKit support
extension UIColor {

    // MARK: Tiers

    static let verified = UIColor(paletteColor: .verified)
    static let diamond = UIColor(paletteColor: .diamond)

    // MARK: Grey Fade

    static let greyFade100 = UIColor(paletteColor: .greyFade100)
    static let greyFade400 = UIColor(paletteColor: .greyFade400)
    static let greyFade600 = UIColor(paletteColor: .greyFade600)
    static let greyFade800 = UIColor(paletteColor: .greyFade800)
    static let greyFade900 = UIColor(paletteColor: .greyFade900)

    // MARK: White Fade

    static let whiteFade100 = UIColor(paletteColor: .whiteFade100)
    static let whiteFade400 = UIColor(paletteColor: .whiteFade400)
    static let whiteFade600 = UIColor(paletteColor: .whiteFade600)
    static let whiteFade800 = UIColor(paletteColor: .whiteFade800)

    // MARK: Grey

    static let grey000 = UIColor(paletteColor: .grey000)
    static let grey050 = UIColor(paletteColor: .grey050)
    static let grey100 = UIColor(paletteColor: .grey100)
    static let grey200 = UIColor(paletteColor: .grey200)
    static let grey300 = UIColor(paletteColor: .grey300)
    static let grey400 = UIColor(paletteColor: .grey400)
    static let grey500 = UIColor(paletteColor: .grey500)
    static let grey600 = UIColor(paletteColor: .grey600)
    static let grey700 = UIColor(paletteColor: .grey700)
    static let grey800 = UIColor(paletteColor: .grey800)
    static let grey900 = UIColor(paletteColor: .grey900)

    // MARK: Blue

    static let blue000 = UIColor(paletteColor: .blue000)
    static let blue100 = UIColor(paletteColor: .blue100)
    static let blue200 = UIColor(paletteColor: .blue200)
    static let blue300 = UIColor(paletteColor: .blue300)
    static let blue400 = UIColor(paletteColor: .blue400)
    static let blue500 = UIColor(paletteColor: .blue500)
    static let blue600 = UIColor(paletteColor: .blue600)
    static let blue700 = UIColor(paletteColor: .blue700)
    static let blue800 = UIColor(paletteColor: .blue800)
    static let blue900 = UIColor(paletteColor: .blue900)

    // MARK: Green

    static let green000 = UIColor(paletteColor: .green000)
    static let green100 = UIColor(paletteColor: .green100)
    static let green200 = UIColor(paletteColor: .green200)
    static let green300 = UIColor(paletteColor: .green300)
    static let green400 = UIColor(paletteColor: .green400)
    static let green500 = UIColor(paletteColor: .green500)
    static let green600 = UIColor(paletteColor: .green600)
    static let green700 = UIColor(paletteColor: .green700)
    static let green800 = UIColor(paletteColor: .green800)
    static let green900 = UIColor(paletteColor: .green900)

    // MARK: Red

    static let red000 = UIColor(paletteColor: .red000)
    static let red100 = UIColor(paletteColor: .red100)
    static let red200 = UIColor(paletteColor: .red200)
    static let red300 = UIColor(paletteColor: .red300)
    static let red400 = UIColor(paletteColor: .red400)
    static let red500 = UIColor(paletteColor: .red500)
    static let red600 = UIColor(paletteColor: .red600)
    static let red700 = UIColor(paletteColor: .red700)
    static let red800 = UIColor(paletteColor: .red800)
    static let red900 = UIColor(paletteColor: .red900)

    // MARK: Orange

    static let orange000 = UIColor(paletteColor: .orange000)
    static let orange100 = UIColor(paletteColor: .orange100)
    static let orange200 = UIColor(paletteColor: .orange200)
    static let orange300 = UIColor(paletteColor: .orange300)
    static let orange400 = UIColor(paletteColor: .orange400)
    static let orange500 = UIColor(paletteColor: .orange500)
    static let orange600 = UIColor(paletteColor: .orange600)
    static let orange700 = UIColor(paletteColor: .orange700)
    static let orange800 = UIColor(paletteColor: .orange800)
    static let orange900 = UIColor(paletteColor: .orange900)

    // MARK: Purple

    static let purple000 = UIColor(paletteColor: .purple000)
    static let purple100 = UIColor(paletteColor: .purple100)
    static let purple200 = UIColor(paletteColor: .purple200)
    static let purple300 = UIColor(paletteColor: .purple300)
    static let purple400 = UIColor(paletteColor: .purple400)
    static let purple500 = UIColor(paletteColor: .purple500)
    static let purple600 = UIColor(paletteColor: .purple600)
    static let purple700 = UIColor(paletteColor: .purple700)
    static let purple800 = UIColor(paletteColor: .purple800)
    static let purple900 = UIColor(paletteColor: .purple900)

    // MARK: Teal

    static let teal000 = UIColor(paletteColor: .teal000)
    static let teal100 = UIColor(paletteColor: .teal100)
    static let teal200 = UIColor(paletteColor: .teal200)
    static let teal300 = UIColor(paletteColor: .teal300)
    static let teal400 = UIColor(paletteColor: .teal400)
    static let teal500 = UIColor(paletteColor: .teal500)
    static let teal600 = UIColor(paletteColor: .teal600)
    static let teal700 = UIColor(paletteColor: .teal700)
    static let teal800 = UIColor(paletteColor: .teal800)
    static let teal900 = UIColor(paletteColor: .teal900)
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
            public static let background = UIColor.semantic.light// previously, grey000
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
    public static let mediumBackground = grey100
    public static let hightlightedBackground = grey050
    public static let lightBlueBackground = blue000
    public static let lightRedBackground = red000
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

    public static let nftBadge = purple600

    // MARK: Indications

    public static let securePinGrey = greyFade400
    public static let addressPageIndicator = blue100
    public static let disclosureIndicator = grey800

    // MARK: Texts

    public static let defaultBadge = blue600
    public static let warningBadge = orange600
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

    public static let dashboardAssetTitle = grey800
    public static let dashboardFiatPriceTitle = grey800

    public static let negativePrice = red400
    public static let positivePrice = green500

    public static let validInput = grey900
    public static let invalidInput = red400

    // MARK: Buttons

    public static let destructiveButton = red600
    public static let successButton = green600
    public static let primaryButton = blue600
    public static let secondaryButton = grey800
    public static let tertiaryButton = grey900
    public static let linkableText = blue600

    public static let primaryButtonTitle = white

    public static let iconLight = grey300
    public static let iconDefault = grey400
    public static let iconSelected = grey400
    public static let iconWarning = orange600
    public static let iconWarningBackground = orange100

    // MARK: Currency

    public static let fiat = green500

    // MARK: Feature Themes

    public static let exchangeAnnouncementButton = grey800
}
