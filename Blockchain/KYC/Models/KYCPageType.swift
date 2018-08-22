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
    case profile
    case address
    case enterPhone
    case confirmPhone
    case verifyIdentity
    case accountStatus
}

extension KYCPageType {
    /// The next page provided that the user successfully entered/selected
    /// information in this page.
    var next: KYCPageType? {
        switch self {
        case .welcome:
            return .country
        case .country:
            return .profile
        case .profile:
            return .address
        case .address:
            return .enterPhone
        case .enterPhone:
            return .confirmPhone
        case .confirmPhone:
            return .verifyIdentity
        case .verifyIdentity:
            return .accountStatus
        case .accountStatus:
            return nil
        }
    }
}
