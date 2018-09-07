//
//  KYCPageModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCPageModel {
    case personalDetails(NabuUser)
    case address(NabuUser, KYCCountry?)
    case phone(NabuUser)
    case verifyIdentity(KYCCountry)
}
