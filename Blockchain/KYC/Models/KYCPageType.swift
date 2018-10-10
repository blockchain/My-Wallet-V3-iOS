//
//  KYCPage.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCPageType {
    typealias PhoneNumber = String

    case welcome
    case country
    case states
    case profile
    case address
    case enterPhone
    case confirmPhone
    case verifyIdentity
    case accountStatus
    case applicationComplete
}

extension KYCPageType {
    /// The next page provided that the user successfully entered/selected
    /// information in this page.
    func nextPage(for user: NabuUser?, country: KYCCountry?) -> KYCPageType? {
        switch self {
        case .welcome:
            return .country
        case .country:
            if let country = country, country.states.count != 0 {
                return .states
            }
            return .profile
        case .states:
            return .profile
        case .profile:
            return .address
        case .address:
            // Skip the enter phone step if the user already has verified their
            // phone number
            if let user = user, let mobile = user.mobile, mobile.verified {
                return .verifyIdentity
            }
            return .enterPhone
        case .enterPhone:
            return .confirmPhone
        case .confirmPhone:
            return .verifyIdentity
        case .verifyIdentity:
            return .applicationComplete
        case .applicationComplete:
            return .accountStatus
        case .accountStatus:
            return nil
        }
    }
}
