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
