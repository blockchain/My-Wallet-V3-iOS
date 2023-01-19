// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAppDomain
import Foundation

extension UIApplication {

    // MARK: - Open the AppStore at the app's page

    public func openAppStore() {
        let url = URL(string: Constants.AppStore.url)!
        open(url)
    }
}
