//
//  KYCAccountStatus.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum KYCAccountStatus: String {
    case none = "NONE"
    case expired = "EXPIRED"
    case approved = "VERIFIED"
    case failed = "REJECTED"
    case pending = "PENDING"
}
