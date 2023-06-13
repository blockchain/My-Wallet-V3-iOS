// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import SwiftUI
import UIKit

extension UIColor {
    public convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }

    public convenience init(light: Color, dark: Color) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        }
    }
}

#endif
