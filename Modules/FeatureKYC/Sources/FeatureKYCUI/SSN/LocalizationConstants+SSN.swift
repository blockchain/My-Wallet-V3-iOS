import Localization

extension LocalizationConstants {
    enum SSN {}
}

extension LocalizationConstants.SSN {
    static let title = NSLocalizedString(
        "Social Security Number (SSN)",
        comment: "Social Security Number (SSN)"
    )
    static let subtitle = NSLocalizedString(
        "Confirm your identity with your SSN",
        comment: "Confirm your identity with your SSN"
    )
    static let why = NSLocalizedString(
        "Why do I need to enter my SSN?",
        comment: "Why do I need to enter my SSN?"
    )
    static let next = NSLocalizedString(
        "Next",
        comment: "Next"
    )
    static let whyTitle = NSLocalizedString(
        "Why do we need your SSN?",
        comment: "Why do we need your SSN?"
    )
    static let whyBody = NSLocalizedString(
        "Recent Federal and state regulation requires us to verify your identity with your SSN. Your data is always encrypted and securely stored. Entering this information won’t impact your credit score.",
        comment: "Recent Federal and state regulation requires us to verify your identity with your SSN. Your data is always encrypted and securely stored. Entering this information won’t impact your credit score."
    )
    static let learnMore = NSLocalizedString(
        "Learn More",
        comment: "Learn More"
    )
    static let gotIt = NSLocalizedString(
        "Got It",
        comment: "Got It"
    )
    static let timedOutTitle = NSLocalizedString(
        "Waiting for verification",
        comment: "Timed out title"
    )
    static let timedOutBody = NSLocalizedString(
        "We are still waiting for your account to be verified. Please check back soon.",
        comment: "Timed out body"
    )
}
