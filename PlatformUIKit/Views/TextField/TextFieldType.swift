//
//  TextFieldType.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LocalizationKit

/// The type of the text field
public enum TextFieldType {
    
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
    
    /// Mnemonic for recovering funds
    case recoveryPhrase
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
             .recoveryPhrase:
            return true
        case .email:
            return false
        }
    }
}

// MARK: - Accessibility

extension TextFieldType {
    /// Provides accessibility attributes for the `TextFieldView`
    var accessibility: Accessibility {
        switch self {
        case .email:
            return Accessibility(id: .value(Accessibility.Identifier.TextFieldView.email))
        case .newPassword:
            return Accessibility(id: .value(Accessibility.Identifier.TextFieldView.newPassword))
        case .confirmNewPassword:
            return Accessibility(id: .value(Accessibility.Identifier.TextFieldView.confirmNewPassword))
        case .password:
            return Accessibility(id: .value(Accessibility.Identifier.TextFieldView.password))
        case .walletIdentifier:
            return Accessibility(id: .value(Accessibility.Identifier.TextFieldView.walletIdentifier))
        case .recoveryPhrase:
            return Accessibility(id: .value(Accessibility.Identifier.TextFieldView.recoveryPhrase))
        }
    }
}

// MARK: - Gesture

extension TextFieldType {
    
    /// This is `true` if the text field should show hints during typing
    var showsHintWhileTyping: Bool {
        switch self {
        case .email:
            return false
        case .password,
             .newPassword,
             .confirmNewPassword,
             .walletIdentifier,
             .recoveryPhrase:
            return true
        }
    }
}

// MARK: - Placeholder

extension TextFieldType {
    /// The placeholder of the text field
    var placeholder: String {
        switch self {
        case .email:
            return LocalizationConstants.TextField.Placeholder.email
        case .newPassword, .password:
            return LocalizationConstants.TextField.Placeholder.password
        case .confirmNewPassword:
            return LocalizationConstants.TextField.Placeholder.confirmPassword
        case .recoveryPhrase:
            return LocalizationConstants.TextField.Placeholder.recoveryPhrase
        case .walletIdentifier:
            return LocalizationConstants.TextField.Placeholder.walletIdentifier
        }
    }
}

// MARK: - Secure

extension TextFieldType {

    /// Returns `true` if the text-field's input has to be secure
    var isSecure: Bool {
        switch self {
        case .email, .walletIdentifier, .recoveryPhrase:
            return false
        case .newPassword, .confirmNewPassword, .password:
            return true
        }
    }
}

extension TextFieldType {
    /// Returns `UITextAutocorrectionType`
    var autocorrectionType: UITextAutocorrectionType {
        return .no
    }
}

extension TextFieldType {
    var returnKeyType: UIReturnKeyType {
        return .done
    }
}

extension TextFieldType {
    
    /// The `UITextContentType` of the textField which can
    /// drive auto-fill behavior.
    var contentType: UITextContentType? {
        switch self {
        case .recoveryPhrase:
            return nil
        case .walletIdentifier:
            return .username
        case .email:
            return .emailAddress
        case .newPassword, .confirmNewPassword, .password:
            /// Disable password suggestions (avoid setting `.password` as value)
            return UITextContentType(rawValue: "")
        }
    }
}
