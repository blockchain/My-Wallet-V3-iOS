//
//  TextValidationFactory.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit

/// A factory for text validators
public final class TextValidationFactory {
        
    private typealias LocalizedString = LocalizationConstants.TextField.Gesture
    
    public final class Password {
        public static var login: TextValidating {
            General.notEmpty
        }
        
        public static var new: NewPasswordValidating {
            NewPasswordTextValidator()
        }
    }
    
    public final class Card {
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
    
    public final class Info {
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
    
    public final class General {
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
    
    public final class Backup {
        public static func mnemonic(words: Set<String>, mnemonicLength: Int = 12) -> MnemonicValidating {
            MnemonicValidator(words: words, mnemonicLength: mnemonicLength)
        }
        
        public static func word(value: String) -> TextValidating {
            WordValidator(word: value)
        }
    }
}
