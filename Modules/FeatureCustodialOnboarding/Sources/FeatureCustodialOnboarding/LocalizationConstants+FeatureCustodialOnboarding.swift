import Localization

typealias L10n = LocalizationConstants.CustodialOnboarding

extension LocalizationConstants {
    enum CustodialOnboarding {}
}

extension LocalizationConstants.CustodialOnboarding {

    static let completeYourProfile = NSLocalizedString("Complete your profile", comment: "Complete your profile")
    static let tradeCryptoToday = NSLocalizedString("Trade crypto today", comment: "Trade crypto today")
    static let verifyYourEmail = NSLocalizedString("Verify your email", comment: "Verify your email")
    static let completeIn30Seconds = NSLocalizedString("Complete in around 30 seconds", comment: "Complete in around 30 seconds")
    static let verifyYourIdentity = NSLocalizedString("Verify your identity", comment: "Verify your identity")
    static let completeIn2Minutes = NSLocalizedString("Complete in around 2 minutes", comment: "Complete in around 2 minutes")
    static let buyCrypto = NSLocalizedString("Buy crypto", comment: "Buy crypto")
    static let completeIn10Seconds = NSLocalizedString("Complete in around 10 seconds", comment: "Complete in around 10 seconds")

    static let beforeYouContinue = NSLocalizedString("Before you continue", comment: "Before you continue")
    static let startTradingCrypto = NSLocalizedString("To start trading crypto, we first need to verify your identity.", comment: "To start trading crypto, we first need to verify your identity.")
    static let verifyMyIdentity = NSLocalizedString("Verify my identity", comment: "Verify my identity")

    static let youDontHaveAnyBalance = NSLocalizedString("You don’t have any balance", comment: "You don’t have any balance")
    static let fundYourAccount = NSLocalizedString("Fund your account to start buying crypto", comment: "Fund your account to start buying crypto")
    static let deposit = NSLocalizedString("Deposit %@", comment: "Deposit %@")

    static let weCouldNotVerify = NSLocalizedString("We couldn't verify your identity", comment: "We couldn't verify your identity")
    static let unableToVerifyGoToDeFi = NSLocalizedString("It seems we're unable to verify your identity.\n\nHowever, you can still use our DeFi Wallet.", comment: "It seems we're unable to verify your identity.\n\nHowever, you can still use our DeFi Wallet.")
    static let goToDeFi = NSLocalizedString("Go to DeFi Wallet", comment: "Go to DeFi Wallet")

    static let done = NSLocalizedString("Done", comment: "Done")
    static let completed = NSLocalizedString("Completed", comment: "Completed")
    static let inReview = NSLocalizedString("In review", comment: "In review")

    static let applicationSubmitted = NSLocalizedString("Application submitted", comment: "Application submitted")
    static let successfullyReceivedInformation = NSLocalizedString("We've successfully received your information.\n\nWe're experiencing high volumes of applications, and we'll notify you of the status of your application via email.", comment: "KYC Pending message")
    static let successfullyReceivedInformationCountdown = NSLocalizedString("We've successfully received your information and it's being reviewed.\n\nThis could take up to **60 seconds**.\nWe'll notify you via email about the status of your application.", comment: "KYC Pending message")
    static let cta = NSLocalizedString("Go to my Account", comment: "KYC Pending: CTA")

    static let phoneNumber = NSLocalizedString("Phone Number", comment: "Phone Number")
    static let weNeedToVerify = NSLocalizedString("We need to verify your phone number", comment: "We need to verify your phone number")
    static let next = NSLocalizedString("Next", comment: "Next")
    static let phoneNumberPlaceholder = NSLocalizedString("(123) 456-7890", comment: "(123) 456-7890")

    static let deviceVerified = NSLocalizedString("Your device is verified!", comment: "Your device is verified!")
    static let successfullyVerified = NSLocalizedString("We've successfully verified the phone number", comment: "We've successfully verified the phone number")

    static let verifyingDevice = NSLocalizedString("Verifying your device", comment: "Verifying your device")
    static let sentALink = NSLocalizedString("We've sent a link via SMS to +1 (123) 456 7890. Follow it to continue with verification.", comment: "We've sent a link via SMS to +1 (123) 456 7890. Follow it to continue with verification.")
    static let resendSMS = NSLocalizedString("Resend SMS", comment: "Resend SMS")

    static let verifyIn60 = NSLocalizedString("Verify in less than 60 seconds ", comment: "Verify in less than 60 seconds")
    static let dateOfBirth = NSLocalizedString("Date of birth", comment: "Date of birth")
    static let addYourDateOfBirth = NSLocalizedString("Add your date of birth and we will auto populate the personal information associated with your phone", comment: "Add your date of birth and we will auto populate the personal information associated with your phone")

    static let confirmYourDetails = NSLocalizedString("Confirm your details", comment: "Confirm your details")
    static let checkYourInformation = NSLocalizedString("Check that your information is correct", comment: "Check that your information is correct")

    static let firstName = NSLocalizedString("First name", comment: "First name")
    static let lastName = NSLocalizedString("Last name", comment: "Last name")
    static let address = NSLocalizedString("Address", comment: "Address")
    static let changeAddress = NSLocalizedString("Change address manually ->", comment: "Change address manually ->")
    static let socialSecurityNumber = NSLocalizedString("Social Security Number (SSN)", comment: "Social Security Number (SSN)")
}
