//
//  KYCPageViewFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Factory for constructing a KYCBaseViewController
class KYCPageViewFactory {

    // swiftlint:disable:next cyclomatic_complexity
    func createFrom(
        pageType: KYCPageType,
        in coordinator: KYCCoordinator,
        payload: KYCPagePayload? = nil
    ) -> KYCBaseViewController {
        switch pageType {
        case .welcome:
            AnalyticsService.shared.trackEvent(title: "kyc_welcome")
            return KYCWelcomeController.make(with: coordinator)
        case .country:
            AnalyticsService.shared.trackEvent(title: "kyc_country")
            return KYCCountrySelectionController.make(with: coordinator)
        case .states:
            AnalyticsService.shared.trackEvent(title: "kyc_states")
            let stateController = KYCStateSelectionController.make(with: coordinator)
            if let payload = payload, case let .countrySelected(country) = payload {
                stateController.country = country
            }
            return stateController
        case .profile:
            AnalyticsService.shared.trackEvent(title: "kyc_profile")
            return KYCPersonalDetailsController.make(with: coordinator)
        case .address:
            AnalyticsService.shared.trackEvent(title: "kyc_address")
            return KYCAddressController.make(with: coordinator)
        case .enterPhone:
            AnalyticsService.shared.trackEvent(title: "kyc_enter_phone")
            return KYCEnterPhoneNumberController.make(with: coordinator)
        case .confirmPhone:
            AnalyticsService.shared.trackEvent(title: "kyc_confirm_phone")
            let confirmPhoneNumberController = KYCConfirmPhoneNumberController.make(with: coordinator)
            if let payload = payload, case let .phoneNumberUpdated(number) = payload {
                confirmPhoneNumberController.phoneNumber = number
            }
            return confirmPhoneNumberController
        case .verifyIdentity:
            AnalyticsService.shared.trackEvent(title: "kyc_verify_identity")
            return KYCVerifyIdentityController.make(with: coordinator)
        case .accountStatus:
            AnalyticsService.shared.trackEvent(title: "kyc_account_status")
            return KYCInformationController.make(with: coordinator)
        case .applicationComplete:
            AnalyticsService.shared.trackEvent(title: "kyc_complete")
            return KYCApplicationCompleteController.make(with: coordinator)
        }
    }
}
