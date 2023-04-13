// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureSuperAppIntro = Bundle.find("FeatureAnnouncements_FeatureAnnouncementsUI.bundle", in: BundleFinder.self)
}
