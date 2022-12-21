// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import ToolKit

/// A factory for text validators
public enum TextValidationFactory {

    private typealias LocalizedString = LocalizationConstants.TextField.Gesture

    public enum Password {
        public static var login: TextValidating {
            General.notEmpty
        }

        public static var new: NewPasswordValidating {
            NewPasswordTextValidator()
        }
    }

    public enum Card {
        public static var number: CardNumberValidator {
            CardNumberValidator()
        }

        public static var expirationDate: TextValidating {
            CardExpirationDateValidator()
        }

        public static var cvv: TextValidating {
            RegexTextValidator(
                regex: .cvv,
                invalidReason: LocalizedString.invalidCVV
            )
        }

        public static var name: TextValidating {
            RegexTextValidator(
                regex: .cardholderName,
                invalidReason: LocalizedString.invalidCardholderName
            )
        }
    }

    public enum Info {
        public static var email: TextValidating {
            RegexTextValidator(
                regex: .email,
                invalidReason: LocalizedString.invalidEmail
            )
        }

        public static var walletIdentifier: TextValidating {
            RegexTextValidator(
                regex: .walletIdentifier,
                invalidReason: LocalizedString.walletId
            )
        }

        public static var mobile: TextValidating {
            MobileNumberValidator()
        }
    }

    public enum Send {
        public static var memo: TextValidating {
            RegexTextValidator(
                regex: .memo,
                invalidReason: LocalizedString.invalidMemo
            )
        }
    }

    public enum General {
        public static var alwaysValid: TextValidating {
            AlwaysValidValidator()
        }

        public static var notEmpty: TextValidating {
            RegexTextValidator(
                regex: .notEmpty,
                invalidReason: nil
            )
        }
    }

    public enum Backup {
        public static func word(value: String) -> TextValidating {
            WordValidator(word: value)
        }
    }
}
