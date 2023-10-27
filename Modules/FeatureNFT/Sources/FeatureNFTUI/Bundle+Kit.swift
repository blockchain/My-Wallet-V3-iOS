// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

private class BundleFinder {}
extension Bundle {
    public static let featureNFTUI = Bundle.find("FeatureNFT_FeatureNFTUI.bundle", in: BundleFinder.self)
}
