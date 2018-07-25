//
//  AuthenticationTwoFactorType.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumeration for different two-factor authentication types.
@objc enum AuthenticationTwoFactorType: Int, RawValued {
    case none = 0
    case yubiKey = 1
    case google = 4
    case sms = 5
}
