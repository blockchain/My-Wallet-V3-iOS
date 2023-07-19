// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import SwiftUI
import ToolKit

extension CryptoCurrency {

    // MARK: UIColor

    public var brandColor: Color {
        assetModel.brandColor
    }

    public var brandUIColor: UIColor {
        assetModel.brandUIColor
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        assetModel.accentColor
    }

    // MARK: Logo Image `ImageResource`

    public var image: Image {
        logoResource.image ?? Image("crypto-placeholder", bundle: .platformUIKit)
    }

    public var logoResource: ImageResource {
        assetModel.logoResource
    }
}
