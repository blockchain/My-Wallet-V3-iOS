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
    func createFrom(
        pageType: KYCPageType,
        in coordinator: KYCCoordinator,
        payload: KYCPagePayload? = nil
    ) -> KYCBaseViewController {
        switch pageType {
        case .welcome:
            return KYCWelcomeController.make(with: coordinator)
        case .country:
            return KYCCountrySelectionController.make(with: coordinator)
        case .profile:
            return KYCPersonalDetailsController.make(with: coordinator)
        case .address:
            return KYCAddressController.make(with: coordinator)
        case .enterPhone:
            return KYCEnterPhoneNumberController.make(with: coordinator)
        case .confirmPhone:
            return KYCConfirmPhoneNumberController.make(with: coordinator)
        case .verifyIdentity:
            return KYCVerifyIdentityController.make(with: coordinator)
        case .accountStatus:
            return KYCInformationController.make(with: coordinator)
        case .applicationComplete:
            return KYCApplicationCompleteController.make(with: coordinator)
        }
    }
}
