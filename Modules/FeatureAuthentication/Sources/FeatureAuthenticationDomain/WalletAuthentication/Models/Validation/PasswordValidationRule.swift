// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A password must contain
public enum PasswordValidationRule: Equatable {

    /// lowercase letter
    case lowercaseLetter

    /// uppercase letter
    case uppercaseLetter

    /// number
    case number

    /// special character
    case specialCharacter

    /// be at least 8 characters long
    case length

    static public let all: [PasswordValidationRule] = [.lowercaseLetter, .uppercaseLetter, .number, .specialCharacter, .length]
}
