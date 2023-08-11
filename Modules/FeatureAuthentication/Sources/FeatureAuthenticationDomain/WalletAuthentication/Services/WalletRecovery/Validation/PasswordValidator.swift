// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol PasswordValidatorAPI {
    func validate(password: String) -> [PasswordValidationRule]
}

public final class PasswordValidator: PasswordValidatorAPI {

    // MARK: - Setup

    public init() {}

    // MARK: - API

    /// Returns a list of missing rules if any
    public func validate(password: String) -> [PasswordValidationRule] {
        PasswordValidationRule
            .all
            .filter {
                !$0.isMatch(for: password)
            }
    }
}

extension PasswordValidationRule {

    func isMatch(for password: String) -> Bool {
        let characterSet: CharacterSet
        switch self {
        case .lowercaseLetter:
            characterSet = .lowercaseLetters
        case .uppercaseLetter:
            characterSet = .uppercaseLetters
        case .number:
            characterSet = .decimalDigits
        case .specialCharacter:
            characterSet = .punctuationCharacters.union(.symbols)
        case .length:
            return password.count > 7
        }

        return password.rangeOfCharacter(from: characterSet) != nil
    }
}

/// Useful for SwiftUI Previews
public final class NoOpPasswordValidator: PasswordValidatorAPI {

    public init() {}

    public func validate(
        password: String
    ) -> [PasswordValidationRule] {
        []
    }
}
