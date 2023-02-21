// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureStaking = Bundle.find("FeatureStaking_FeatureStakingUI.bundle", in: BundleFinder.self)
}
