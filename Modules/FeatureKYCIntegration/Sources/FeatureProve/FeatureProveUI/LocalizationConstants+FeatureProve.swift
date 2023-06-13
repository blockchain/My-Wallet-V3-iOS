// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {
    enum BeginVerification {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Begin Verification: Title"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Let’s gather your information",
                comment: "Begin Verification: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Tap continue to begin the process.",
                comment: "Begin Verification: Body subtitle"
            )
        }

        enum Footer {

            static let title = NSLocalizedString(
                "By selecting “Continue”, you agree to the",
                comment: "Begin Verification: Footer title without terms part"
            )

            static let titleTerms = NSLocalizedString(
                "Blockchain.com Privacy Policy",
                comment: "Begin Verification: Footer terms part"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Begin Verification: Continue Button"
            )
        }
    }
}

extension LocalizationConstants {
    enum EnterInformation {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Enter Personal Information: Title"
        )

        static let loadingTitle = NSLocalizedString(
            "Verifying your information",
            comment: "Enter Personal Information: Verifying your information loading"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Enter your information",
                comment: "Enter Personal Information: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Please add your date of birth.",
                comment: "Enter Personal Information: Body subtitle"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Enter Personal Information: Continue Button"
            )
        }
    }
}

extension LocalizationConstants.EnterInformation.Body {
    enum Form {

        static let dateOfBirthInputTitle = NSLocalizedString(
            "Date of birth",
            comment: "Enter Personal Information: Date Of Birth Input Title"
        )

        static let dateOfBirthInputHint = NSLocalizedString(
            "You must be 18 years or older.",
            comment: "Enter Personal Information: Date Of Birth Input Hint"
        )
    }
}

extension LocalizationConstants {
    enum EnterFullInformation {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Enter Full Personal Information: Title"
        )

        static let loadingTitle = NSLocalizedString(
            "Verifying your information",
            comment: "Enter Full Personal Information: Verifying your information loading"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Enter your information",
                comment: "Enter Full Personal Information: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Please add your phone number and\ndate of birth.",
                comment: "Enter Full Personal Information: Body subtitle"
            )
        }

        enum Footer {

            static let title = NSLocalizedString(
                "We’ll send you a link to verify your identity.",
                comment: "Enter Full Personal Information: Footer title"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Enter Full Personal Information: Continue Button"
            )
        }
    }
}

extension LocalizationConstants.EnterFullInformation.Body {
    enum Form {

        static let phoneInputTitle = NSLocalizedString(
            "Phone number",
            comment: "Enter Full Personal Information: Phone number Input Title"
        )

        static let phoneInputHint = NSLocalizedString(
            "Verification only supports US(+1) phone numbers",
            comment: "Enter Full Personal Information: Phone number Input Hint"
        )

        static let phoneInputPlaceholder = NSLocalizedString(
            "Enter your phone number",
            comment: "Enter Full Personal Information: Phone number Input Placeholder"
        )

        static let phoneInputPrefix = "+1"

        static let dateOfBirthInputTitle = NSLocalizedString(
            "Date of birth",
            comment: "Enter Full Personal Information: Date Of Birth Input Title"
        )

        static let dateOfBirthInputHint = NSLocalizedString(
            "You must be 18 years or older.",
            comment: "Enter Full Personal Information: Date Of Birth Input Hint"
        )
    }
}

extension LocalizationConstants.EnterFullInformation.Body {
    enum VerifyingPhone {

        static let title = NSLocalizedString(
            "Verification processing",
            comment: "Verifying Phone: Title"
        )

        static let subttitle = NSLocalizedString(
            "We’ve sent a link to you via SMS. Follow it to continue with verification.",
            comment: "Verifying Phone: Subttitle"
        )

        static let resendSMSButton = NSLocalizedString(
            "Resend SMS",
            comment: "Verifying Phone: Resend SMS button"
        )

        static let resendSMSInTimeButton = NSLocalizedString(
            "Resend SMS in %@",
            comment: "Verifying Phone: Resend SMS button"
        )
    }
}

extension LocalizationConstants {
    enum ConfirmInformation {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Confirm Personal Information: Title"
        )

        static let loadingTitle = NSLocalizedString(
            "Verifying your account",
            comment: "Confirm Personal Information: Verifying your account loading"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Confirm your information",
                comment: "Confirm Personal Information: Body title"
            )
        }

        enum Buttons {

            static let continueTitle = NSLocalizedString(
                "Continue",
                comment: "Confirm Personal Information: Continue Button"
            )

            static let enterAddressManuallyPrefix = NSLocalizedString(
                "or",
                comment: "Confirm Personal Information: `Or` enter address manually Button"
            )

            static let enterAddressManuallyTitle = NSLocalizedString(
                "enter manually →",
                comment: "Confirm Personal Information: enter address manually Button"
            )
        }
    }
}

extension LocalizationConstants.ConfirmInformation.Body {
    enum Form {

        static let firstNameInputTitle = NSLocalizedString(
            "First name",
            comment: "Confirm Personal Information: First Name Input Title"
        )

        static let firstNameInputPlaceholder = NSLocalizedString(
            "Enter your first name",
            comment: "Confirm Personal Information: First Name Input placeholder"
        )

        static let lastNameInputTitle = NSLocalizedString(
            "Last name",
            comment: "Confirm Personal Information: Last Name Input Title"
        )

        static let lastNameInputPlaceholder = NSLocalizedString(
            "Enter your last name",
            comment: "Confirm Personal Information: Last Name Input placeholder"
        )

        static let addressNameInputTitle = NSLocalizedString(
            "Address",
            comment: "Confirm Personal Information: Address Input Title"
        )

        static let addressInputPlaceholder = NSLocalizedString(
            "Enter your current address",
            comment: "Confirm Personal Information: Address Input Title"
        )

        static let dateOfBirthInputTitle = NSLocalizedString(
            "Date of birth",
            comment: "Confirm Personal Information: Date Of Birth Input Title"
        )

        static let dateOfBirthInputHint = NSLocalizedString(
            "You must be 18 years or older.",
            comment: "Confirm Personal Information: Date Of Birth Input Hint"
        )

        static let phoneInputTitle = NSLocalizedString(
            "Phone number",
            comment: "Confirm Personal Information: Phone Input Title"
        )

        static let phoneInputHint = NSLocalizedString(
            "This information cannot be modified",
            comment: "Confirm Personal Information: Phone Input Hint"
        )
    }
}

extension LocalizationConstants {
    enum SuccessfullyVerified {

        static let title = NSLocalizedString(
            "Verify your account",
            comment: "Successfully Verified: Title"
        )

        enum Body {

            static let title = NSLocalizedString(
                "Successfully verified",
                comment: "Successfully Verified: Body title"
            )

            static let subtitle = NSLocalizedString(
                "Congratulations! We successfully verified your identity. You can now buy, sell and swap cryptocurrencies at Blockchain.com",
                comment: "Successfully Verified: Body subtitle"
            )
        }

        enum Buttons {

            static let finishTitle = NSLocalizedString(
                "Get Started",
                comment: "Successfully Verified: Get started Button"
            )
        }
    }
}
