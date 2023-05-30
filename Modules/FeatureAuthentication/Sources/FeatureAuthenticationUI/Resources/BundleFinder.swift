// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

extension Bundle {

    static var authentication: Bundle {
        class BundleFinder {}
        return Bundle.find("FeatureAuthentication_FeatureAuthenticationUI.bundle", in: BundleFinder.self)
    }
}
