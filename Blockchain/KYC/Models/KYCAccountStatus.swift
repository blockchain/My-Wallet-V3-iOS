//
//  KYCAccountStatus.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCAccountStatus: String {
    case approved = "VERIFIED"
    case expired = "EXPIRED"
    case failed = "REJECTED"
    case none = "NONE"
    case pending = "PENDING"
    case underReview = "UNDER_REVIEW"
}
