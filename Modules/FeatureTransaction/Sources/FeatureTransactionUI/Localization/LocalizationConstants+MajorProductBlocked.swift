// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    public enum MajorProductBlocked {}
}

extension LocalizationConstants.MajorProductBlocked {
    public static let title = NSLocalizedString(
        "Trading Restricted",
        comment: "EU_5_SANCTION card title."
    )

    public static let ctaButtonLearnMore = NSLocalizedString(
        "Learn More",
        comment: "EU_5_SANCTION card CTA button title."
    )

    public static let defaultMessage = NSLocalizedString(
        "We are working hard so that you get the most of all our products. We’ll let you know as soon as we can!",
        comment: "This operation cannot be performed at this time. Please try again later."
    )

    public static let ok = NSLocalizedString(
        "OK",
        comment: "OK"
    )

    enum Earn {
        static let notEligibleTitle = NSLocalizedString("We’re not in your region yet", comment: "Staking: We’re not in your region yet")
        static let notEligibleMessage = NSLocalizedString("%@ Rewards for %@ are currently unavailable in your region.\n\nWe are working hard so that you get the most of all our products. We’ll let you know as soon as we can!", comment: "Staking: %@ Rewards for %@ are currently unavailable in your region.\n\nWe are working hard so that you get the most of all our products. We’ll let you know as soon as we can!")

        enum Product {
            static let staking = NSLocalizedString("Staking", comment: "Staking: Staking")
            static let passive = NSLocalizedString("Passive", comment: "Staking: Passive")
            static let active = NSLocalizedString("Active", comment: "Staking: Active")
        }
    }
}
