// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

extension UIFont {

    private static func fontName(for weight: Typography.Weight) -> String {
        switch weight {
        case .regular:
            return Typography.FontResource.interRegular.rawValue
        case .medium:
            return Typography.FontResource.interMedium.rawValue
        case .semibold:
            return Typography.FontResource.interSemibold.rawValue
        case .bold:
            return Typography.FontResource.interBold.rawValue
        }
    }

    public static func main(_ weight: Typography.Weight, _ size: CGFloat) -> UIFont {
        UIFont(name: fontName(for: weight), size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
