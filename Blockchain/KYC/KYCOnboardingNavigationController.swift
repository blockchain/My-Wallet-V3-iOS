//
//  KYCOnboardingNavigationController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// NOTE: - This class prefetches some of the data to mitigate loading states in subsequent view controllers
final class KYCOnboardingNavigationController: UINavigationController {

    // MARK: - Initialization

    class func make() -> KYCOnboardingNavigationController {
        let controller = makeFromStoryboard()
        return controller
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // TODO: prefetch data...
    }
}
