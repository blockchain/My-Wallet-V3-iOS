// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureExternalTradingMigration = Bundle.find("FeatureExternalTradingMigration_FeatureExternalTradingMigrationUI.bundle", in: BundleFinder.self)
}
