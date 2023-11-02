// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

    /// Email field
    case email

    /// New password field. Sometimes appears alongside `.confirmNewPassword`
    case newPassword

    /// New password confirmation field. Always alongside `.newPassword`
    case confirmNewPassword

    /// Password for auth
    case password

    /// Current password for changing to new password
    case currentPassword

    /// Mobile phone number entry
    case mobile

    /// One time code entry
    case oneTimeCode

    /// A description of a event
    case description

    /// A memo of a transaction.
    case memo

    /// A crypto address type
    case cryptoAddress
}

// MARK: - Debug

extension TextFieldType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .memo:
            "memo"
        case .description:
            "description"
        case .email:
            "email"
        case .newPassword:
            "new-password"
        case .confirmNewPassword:
            "confirm-new-password"
        case .password:
            "password"
        case .currentPassword:
            "current-password"
        case .mobile:
            "mobile-number"
        case .oneTimeCode:
            "one-time-code"
        case .cardholderName:
            "cardholder-name"
        case .expirationDate:
            "expiry-date"
        case .cardCVV:
            "card-cvv"
        case .cardNumber:
            "card-number"
        case .addressLine:
            "address-line"
        case .city:
            "city"
        case .state:
            "state"
        case .postcode:
            "post-code"
        case .personFullName:
            "person-full-name"
        case .cryptoAddress:
            "crypto-address"
        }
    }
}

// MARK: - Information Sensitivity

extension TextFieldType {

    /// Whether the text field should cleanup on backgrounding
    var requiresCleanupOnBackgroundState: Bool {
        switch self {
        case .password,
             .currentPassword,
             .newPassword,
             .confirmNewPassword,
             .oneTimeCode,
             .cardNumber,
             .cardCVV:
            true
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
             .cryptoAddress,
             .memo:
            false
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
        case .currentPassword:
            return .id(AccessibilityId.currentPassword)
        case .mobile:
            return .id(AccessibilityId.mobileVerification)
        case .oneTimeCode:
            return .id(AccessibilityId.oneTimeCode)
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
        case .memo:
            return .id(AccessibilityId.memo)
        }
    }

    /// This is `true` if the text field should show hints during typing
    var showsHintWhileTyping: Bool {
        switch self {
        case .email,
             .addressLine,
             .city,
             .postcode,
             .personFullName,
             .state,
             .mobile,
             .cardCVV,
             .expirationDate,
             .cardholderName,
             .description,
             .cardNumber,
             .memo:
            false
        case .password,
             .currentPassword,
             .newPassword,
             .confirmNewPassword,
             .oneTimeCode,
             .cryptoAddress:
            true
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
        case .memo:
            return LocalizedString.noMemo
        case .cryptoAddress:
            return LocalizedString.addressOrDomain
        case .password,
             .currentPassword,
             .newPassword,
             .confirmNewPassword,
             .email,
             .addressLine,
             .city,
             .postcode,
             .personFullName,
             .state,
             .mobile,
             .cardholderName,
             .cardNumber:
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
        case .password:
            return LocalizedString.password
        case .currentPassword:
            return LocalizedString.currentPassword
        case .newPassword:
            return LocalizedString.newPassword
        case .confirmNewPassword:
            return LocalizedString.confirmNewPassword
        case .mobile:
            return LocalizedString.mobile
        case .oneTimeCode:
            return LocalizedString.oneTimeCode
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
        case .memo:
            return ""
        }
    }

    // `UIKeyboardType` of the textField
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            .emailAddress
        case .newPassword,
             .confirmNewPassword,
             .password,
             .currentPassword,
             .oneTimeCode,
             .description,
             .cryptoAddress,
             .memo:
            .default
        case .mobile:
            .phonePad
        case .expirationDate, .cardCVV, .cardNumber:
            .numberPad
        case .addressLine,
             .cardholderName,
             .personFullName,
             .city,
             .state,
             .postcode:
            .asciiCapable
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .oneTimeCode:
            .allCharacters
        case .cardholderName,
             .city,
             .state,
             .personFullName,
             .addressLine:
            .words
        case .password,
             .currentPassword,
             .newPassword,
             .confirmNewPassword,
             .email,
             .mobile,
             .cardCVV,
             .expirationDate,
             .cardNumber,
             .postcode,
             .description,
             .cryptoAddress,
             .memo:
            .none
        }
    }

    /// Returns `true` if the text-field's input has to be secure
    var isSecure: Bool {
        switch self {
        case .email,
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
             .cryptoAddress,
             .memo:
            false
        case .newPassword, .confirmNewPassword, .password, .currentPassword:
            true
        }
    }

    /// Returns `UITextAutocorrectionType`
    var autocorrectionType: UITextAutocorrectionType { .no }

    /// The `UITextContentType` of the textField which can
    /// drive auto-fill behavior.
    var contentType: UITextContentType? {
        switch self {
        case .mobile:
            .telephoneNumber
        case .cardNumber:
            .creditCardNumber
        case .cardholderName:
            .name
        case .expirationDate,
             .cardCVV,
             .description,
             .cryptoAddress,
             .memo:
            nil
        case .email:
            .emailAddress
        case .oneTimeCode:
            .oneTimeCode
        case .newPassword, .confirmNewPassword:
            .newPassword
        case .password, .currentPassword:
            /// Disable password suggestions (avoid setting `.password` as value)
            UITextContentType(rawValue: "")
        case .addressLine(let line):
            switch line {
            case 1: // Line 1
                .streetAddressLine1
            default: // 2
                .streetAddressLine2
            }
        case .city:
            .addressCity
        case .state:
            .addressState
        case .postcode:
            .postalCode
        case .personFullName:
            .name
        }
    }
}
