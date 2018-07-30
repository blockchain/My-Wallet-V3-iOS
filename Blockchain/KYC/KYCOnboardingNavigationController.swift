//
//  KYCOnboardingNavigationController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// Set of requirements that every view controller in the KYC flow must conform to.
protocol KYCOnboardingNavigation: class {
    /// Segue identifier of the proceeding screen.
    var segueIdentifier: String? { get }
    /// Primary button used to advance the on-boarding flow.
    var primaryButton: PrimaryButton! { get }
    /// Action dispatched by the primary button when tapped.
    func primaryButtonTapped(_ sender: Any)
}

/// Entry point to the KYC flow
final class KYCOnboardingNavigationController: UINavigationController {
    // TODO: implement class body
}
