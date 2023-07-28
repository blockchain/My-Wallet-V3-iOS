// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit

extension AssetModel {

    // MARK: - UIColor

    public var brandColor: Color {
        Color(brandUIColor)
    }

    /// The brand color.
    public var brandUIColor: UIColor {
        switch kind {
        case .coin:
            if let match = CustodialCoinCode.allCases.first(where: { $0.rawValue == code }) {
                return UIColor(hex: match.spotColor) ?? .black
            }
            return spotUIColor ?? .black
        case .erc20:
            return spotUIColor
                ?? UIColor(hex: ERC20Code.spotColor(code: code))!
        case .celoToken:
            return spotUIColor ?? .black
        case .fiat:
            return .fiat
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        brandUIColor.withAlphaComponent(0.15)
    }

    private var spotUIColor: UIColor? {
        spotColor.flatMap(UIColor.init(hex:))
    }
}
