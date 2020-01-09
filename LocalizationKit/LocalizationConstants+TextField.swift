//
//  LocalizationConstants+TextField.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension LocalizationConstants {
    struct TextField {
        public struct Placeholder {
            public static let email = NSLocalizedString(
                "Your email",
                comment: "Placeholder for email text field"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Placeholder for password text field"
            )
            public static let confirmPassword = NSLocalizedString(
                "Confirm password",
                comment: "Placeholder for confirm password text field"
            )
            public static let recoveryPhrase = NSLocalizedString(
                "Recovery passphrase",
                comment: "Placeholder for recovery passphrase text field"
            )
            public static let walletIdentifier = NSLocalizedString(
                "Wallet Identifier",
                comment: "Placeholder for wallet identifier text field"
            )
        }
        
        public struct PasswordScore {
            public static let weak = NSLocalizedString(
                "Weak",
                comment: "Label for a Weak password score in password text field"
            )
            public static let normal = NSLocalizedString(
                "Medium",
                comment: "Label for a Normal password score in password text field"
            )
            public static let strong = NSLocalizedString(
                "Strong",
                comment: "Label for a Strong password score in password text field"
            )
        }
        
        public struct Gesture {
            public static let passwordMismatch = NSLocalizedString(
                "Password do not match",
                comment: "Error label when two passwords do not match"
            )
            public static let invalidEmail = NSLocalizedString(
                "Email address is not valid",
                comment: "Error label when email address is not valid"
            )
            public static let invalidRecoveryPhrase = NSLocalizedString(
                "Invalid recovery phrase. Please try again,",
                comment: "Error label when the recovery phrase is incorrect"
            )
            public static let walletId = NSLocalizedString(
                "Wallet id is not valid",
                comment: "Error label when wallet id is not valid"
            )
        }
    }
}
