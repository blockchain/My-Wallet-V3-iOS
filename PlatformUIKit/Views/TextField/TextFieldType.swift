//
//  TextFieldType.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Localization
import ToolKit

/// The type of the text field
public enum TextFieldType: Hashable {
    
    /// Address line
    case addressLine(Int)
    
    /// City
    case city
    
    /// State (country)
    case state
    
    /// Post code
    case postcode
    
    /// Person full name
    case personFullName
    
    /// Cardholder name
    case cardholderName
    
    /// Expiry date formatted as MMyy
    case expirationDate
    
    /// CVV
    case cardCVV

    /// Credit card number
    case cardNumber
    
    /// Wallet identifier field
    case walletIdentifier
    
    /// Email field
    case email
    
    /// New password field. Sometimes appears alongside `.confirmNewPassword`
    case newPassword
    
    /// New password confirmation field. Always alongside `.newPassword`
    case confirmNewPassword
    
    /// Password for auth
    case password
    
    /// A single word from the mnemonic used for backup verification.
    /// The index is the index of the word in the mnemonic.
    case backupVerification(index: Int)
    
    /// Mobile phone number entry
    case mobile
    
    /// One time code entry
    case oneTimeCode

    /// A description of a event
    case description

    /// A crypto address type
    case cryptoAddress
}

// MARK: - Debug

extension TextFieldType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .walletIdentifier:
            return "wallet-identifier"
        case .description:
            return "description"
        case .email:
            return "email"
        case .newPassword:
            return "new-password"
        case .confirmNewPassword:
            return "confirm-new-password"
        case .password:
            return "password"
        case .backupVerification(let index):
            return "backup-verification-\(index)"
        case .mobile:
            return "mobile-number"
        case .oneTimeCode:
            return "one-time-code"
        case .cardholderName:
            return "cardholder-name"
        case .expirationDate:
            return "expiry-date"
        case .cardCVV:
            return "card-cvv"
        case .cardNumber:
            return "card-number"
        case .addressLine:
            return "address-line"
        case .city:
            return "city"
        case .state:
            return "state"
        case .postcode:
            return "post-code"
        case .personFullName:
            return "person-full-name"
        case .cryptoAddress:
            return "crypto-address"
        }
    }
}

// MARK: - Information Sensitivity

extension TextFieldType {
    
    /// Whether the text field should cleanup on backgrounding
    var requiresCleanupOnBackgroundState: Bool {
        switch self {
        case .walletIdentifier,
             .password,
             .newPassword,
             .confirmNewPassword,
             .backupVerification,
             .oneTimeCode,
             .cardNumber,
             .cardCVV:
            return true
        case .email,
             .mobile,
             .personFullName,
             .city,
             .state,
             .addressLine,
             .postcode,
             .cardholderName,
             .description,
             .expirationDate,
             .cryptoAddress:
            return false
        }
    }
}

// MARK: - Accessibility

extension TextFieldType {
    /// Provides accessibility attributes for the `TextFieldView`
    var accessibility: Accessibility {
        typealias AccessibilityId = Accessibility.Identifier.TextFieldView
        switch self {
        case .description:
            return .id(AccessibilityId.description)
        case .cardNumber:
            return .id(AccessibilityId.Card.number)
        case .cardCVV:
            return .id(AccessibilityId.Card.cvv)
        case .expirationDate:
            return .id(AccessibilityId.Card.expirationDate)
        case .cardholderName:
            return .id(AccessibilityId.Card.name)
        case .email:
            return .id(AccessibilityId.email)
        case .newPassword:
            return .id(AccessibilityId.newPassword)
        case .confirmNewPassword:
            return .id(AccessibilityId.confirmNewPassword)
        case .password:
            return .id(AccessibilityId.password)
        case .walletIdentifier:
            return .id(AccessibilityId.walletIdentifier)
        case .mobile:
            return .id(AccessibilityId.mobileVerification)
        case .oneTimeCode:
            return .id(AccessibilityId.oneTimeCode)
        case .backupVerification:
            return .id(AccessibilityId.backupVerification)
        case .addressLine(let number):
            return .id("\(AccessibilityId.addressLine)-\(number)")
        case .personFullName:
            return .id(AccessibilityId.personFullName)
        case .city:
            return .id(AccessibilityId.city)
        case .state:
            return .id(AccessibilityId.state)
        case .postcode:
            return .id(AccessibilityId.postCode)
        case .cryptoAddress:
            return .id(AccessibilityId.cryptoAddress)
        }
    }
    
    /// This is `true` if the text field should show hints during typing
    var showsHintWhileTyping: Bool {
        switch self {
        case .email,
             .backupVerification,
             .addressLine,
             .city,
             .postcode,
             .personFullName,
             .state,
             .mobile,
             .cardCVV,
             .expirationDate,
             .cardholderName,
             .cardNumber,
             .description:
             return false
        case .password,
             .newPassword,
             .confirmNewPassword,
             .walletIdentifier,
             .oneTimeCode,
             .cryptoAddress:
            return true
        }
    }
    
    /// The title of the text field
    var placeholder: String {
        typealias LocalizedString = LocalizationConstants.TextField.Placeholder
        switch self {
        case .cardCVV:
            return LocalizedString.cvv
        case .expirationDate:
            return LocalizedString.expirationDate
        case .oneTimeCode:
            return LocalizedString.oneTimeCode
        case .description:
            return LocalizedString.noDescription
        case .password,
             .newPassword,
             .confirmNewPassword,
             .walletIdentifier,
             .email,
             .backupVerification,
             .addressLine,
             .city,
             .postcode,
             .personFullName,
             .state,
             .mobile,
             .cardholderName,
             .cardNumber,
             .cryptoAddress:
            return ""
        }
    }

    /// The title of the text field
    var title: String {
        typealias LocalizedString = LocalizationConstants.TextField.Title
        switch self {
        case .description:
            return LocalizedString.description
        case .cardholderName:
            return LocalizedString.Card.name
        case .expirationDate:
            return LocalizedString.Card.expirationDate
        case .cardNumber:
            return LocalizedString.Card.number
        case .cardCVV:
            return LocalizedString.Card.cvv
        case .email:
            return LocalizedString.email
        case .newPassword, .password:
            return LocalizedString.password
        case .confirmNewPassword:
            return LocalizedString.confirmPassword
        case .mobile:
            return LocalizedString.mobile
        case .oneTimeCode:
            return LocalizedString.oneTimeCode
        case .walletIdentifier:
            return LocalizedString.walletIdentifier
        case .backupVerification(index: let index):
            return index.placeholder
        case .addressLine(let number):
            return "\(LocalizedString.addressLine) \(number)"
        case .city:
            return LocalizedString.city
        case .state:
            return LocalizedString.state
        case .postcode:
            return LocalizedString.postCode
        case .personFullName:
            return LocalizedString.fullName
        case .cryptoAddress:
            return ""
        }
    }
    
    // `UIKeyboardType` of the textField
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .walletIdentifier,
             .newPassword,
             .confirmNewPassword,
             .password,
             .backupVerification,
             .oneTimeCode,
             .description,
             .cryptoAddress:
            return .default
        case .mobile:
            return .phonePad
        case .expirationDate, .cardCVV, .cardNumber:
            return .numberPad
        case .addressLine,
             .cardholderName,
             .personFullName,
             .city,
             .state,
             .postcode:
            return .asciiCapable
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .oneTimeCode:
            return .allCharacters
        case .cardholderName,
             .city,
             .state,
             .personFullName,
             .addressLine:
            return .words
        case .backupVerification,
             .password,
             .newPassword,
             .confirmNewPassword,
             .walletIdentifier,
             .email,
             .mobile,
             .cardCVV,
             .expirationDate,
             .cardNumber,
             .postcode,
             .description,
             .cryptoAddress:
            return .none
        }
    }

    /// Returns `true` if the text-field's input has to be secure
    var isSecure: Bool {
        switch self {
        case .email,
             .walletIdentifier,
             .backupVerification,
             .cardCVV,
             .cardholderName,
             .expirationDate,
             .cardNumber,
             .mobile,
             .oneTimeCode,
             .addressLine,
             .city,
             .state,
             .postcode,
             .personFullName,
             .description,
             .cryptoAddress:
            return false
        case .newPassword, .confirmNewPassword, .password:
            return true
        }
    }

    /// Returns `UITextAutocorrectionType`
    var autocorrectionType: UITextAutocorrectionType { .no }
    
    /// The `UITextContentType` of the textField which can
    /// drive auto-fill behavior.
    var contentType: UITextContentType? {
        switch self {
        case .mobile:
            return .telephoneNumber
        case .cardNumber:
            return .creditCardNumber
        case .cardholderName:
            return .name
        case .expirationDate,
             .cardCVV,
             .backupVerification,
             .description,
             .cryptoAddress:
            return nil
        case .walletIdentifier:
            return .username
        case .email:
            return .emailAddress
        case .oneTimeCode:
            if #available(iOS 12.0, *) {
                return .oneTimeCode
            } else {
                return UITextContentType(rawValue: "")
            }
        case .newPassword, .confirmNewPassword:
            if #available(iOS 12.0, *) {
                return .newPassword
            } else {
                return UITextContentType(rawValue: "")
            }
        case .password:
            /// Disable password suggestions (avoid setting `.password` as value)
            return UITextContentType(rawValue: "")
        case .addressLine(let line):
            switch line {
            case 1: // Line 1
                return .streetAddressLine1
            default: // 2
                return .streetAddressLine2
            }
        case .city:
            return .addressCity
        case .state:
            return .addressState
        case .postcode:
            return .postalCode
        case .personFullName:
            return .name
        }
    }
}

private extension Int {
    typealias Index = LocalizationConstants.VerifyBackupScreen.Index
    var placeholder: String {
        switch self {
        case 0:
            return Index.first
        case 1:
            return Index.second
        case 2:
            return Index.third
        case 3:
            return Index.fourth
        case 4:
            return Index.fifth
        case 5:
            return Index.sixth
        case 6:
            return Index.seventh
        case 7:
            return Index.eighth
        case 8:
            return Index.ninth
        case 9:
            return Index.tenth
        case 10:
            return Index.eleventh
        case 11:
            return Index.twelfth
        default:
            return ""
        }
    }
    
}
