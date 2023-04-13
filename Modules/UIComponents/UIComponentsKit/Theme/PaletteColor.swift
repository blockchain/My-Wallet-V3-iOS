// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import UIKit

extension UIColor {
    convenience init(paletteColor: PaletteColor) {
        let colorName = paletteColor.rawValue.capitalizeFirstLetter
        self.init(named: colorName, in: Bundle.UIComponents, compatibleWith: nil)!
    }
}

extension Color {
    init(paletteColor: PaletteColor) {
        let colorName = paletteColor.rawValue.capitalizeFirstLetter
        self.init(colorName, bundle: Bundle.UIComponents)
    }
}

/// A enum defining the color as define by Blockchain's Design System
///
/// - Note: When adding a new color in `Colors.xcassets` its first letter should be capitized, eg `TierSilver`,
/// this does not apply for the name of the case in the enum.
///
/// Reference: https://www.figma.com/file/MWCxP6khQHkDZSLEew6mLqcQ/iOS-Visual-consistency-update?node-id=68%3A0
enum PaletteColor: String, CaseIterable {

    // MARK: Blue

    case blue000
    case blue100
    case blue200
    case blue300
    case blue400
    case blue500
    case blue600
    case blue700
    case blue800
    case blue900

    // MARK: Green

    case green000
    case green100
    case green200
    case green300
    case green400
    case green500
    case green600
    case green700
    case green800
    case green900

    // MARK: Grey

    case grey000
    case grey050
    case grey100
    case grey200
    case grey300
    case grey400
    case grey500
    case grey600
    case grey700
    case grey800
    case grey900

    // MARK: GreyFade

    case greyFade100
    case greyFade400
    case greyFade600
    case greyFade800
    case greyFade900

    // MARK: Orange

    case orange000
    case orange100
    case orange200
    case orange300
    case orange400
    case orange500
    case orange600
    case orange700
    case orange800
    case orange900

    // MARK: Purple

    case purple000
    case purple100
    case purple200
    case purple300
    case purple400
    case purple500
    case purple600
    case purple700
    case purple800
    case purple900

    // MARK: Red

    case red000
    case red100
    case red200
    case red300
    case red400
    case red500
    case red600
    case red700
    case red800
    case red900

    // MARK: Teal

    case teal000
    case teal100
    case teal200
    case teal300
    case teal400
    case teal500
    case teal600
    case teal700
    case teal800
    case teal900

    // MARK: White

    case white

    // MARK: WhiteFade

    case whiteFade100
    case whiteFade400
    case whiteFade600
    case whiteFade800

    // MARK: KYC Verification Tiers

    case verified
    case diamond
}
