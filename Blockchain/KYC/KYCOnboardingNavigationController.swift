//
//  KYCOnboardingNavigationController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

/// IMPORTANT:
/// - Every view controller in the KYC flow must conform to this protocol.
/// - segueIdentifier refers to the identifier of the proceeding screen.
protocol KYCOnboardingNavigation: class {
    func primaryButtonTapped(_ sender: Any)

    var primaryButton: PrimaryButton! { get }

    var segueIdentifier: String? { get }
}

/// Entry point to the KYC flow
/// NOTE: - This class prefetches some of the data to mitigate loading states in subsequent view controllers
final class KYCOnboardingNavigationController: UINavigationController {

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        KYCCountrySelectionDataSource.dataSource.delegate = self
        KYCCountrySelectionDataSource.dataSource.fetchListOfCountries()
    }
}

// MARK: - HTTPRequestErrorDelegate

extension KYCOnboardingNavigationController: HTTPRequestErrorDelegate {
    func handleClientError(_ error: Error) {
        Logger.shared.error(error.localizedDescription)
        AlertViewPresenter.shared.standardError(
            message: "There was a problem with your request. Please try again in a moment.",
            title: "Error",
            in: self
        )
    }

    func handlePayloadError(_ error: HTTPRequestPayloadError) {
        Logger.shared.error(error.localizedDescription)
        AlertViewPresenter.shared.standardError(
            message: "There was a problem with your request. Please try again in a moment.",
            title: "Error",
            in: self
        )
    }

    func handleServerError(_ error: HTTPURLResponseError) {
        Logger.shared.error(error.localizedDescription)
        AlertViewPresenter.shared.standardError(
            message: "There was a problem with your request. Please try again in a moment.",
            title: "Error",
            in: self
        )
    }
}
