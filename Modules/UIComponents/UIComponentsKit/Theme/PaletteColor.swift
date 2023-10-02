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
    case blue400
    case blue600
    case blue700
    case blue900

    // MARK: Green

    case green000
    case green400
    case green500
    case green600

    // MARK: Grey

    case grey000
    case grey050
    case grey100
    case grey200
    case grey400
    case grey600
    case grey800
    case grey900

    // MARK: GreyFade

    case greyFade800
    case greyFade900

    // MARK: Orange

    case orange000
    case orange400
    case orange600

    // MARK: Red

    case red000
    case red100
    case red400
    case red500
    case red600

    // MARK: White

    case white
}
