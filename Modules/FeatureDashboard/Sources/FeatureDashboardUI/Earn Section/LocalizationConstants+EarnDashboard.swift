import Foundation
import enum Localization.LocalizationConstants

extension LocalizationConstants {

    enum EarnDashboard {

        static let sectionTitle = NSLocalizedString("Earn", comment: "Title for Earn section on Dashboard")
        static let manageButtonTitle = NSLocalizedString("Manage", comment: "Title for Manage button on Earn Section")

        enum EmptyState {
            static let title = NSLocalizedString(
                "Earn up to 10%",
                comment: "title for Earn section on Dashboard"
            )

            static let subtitle = NSLocalizedString(
                "Put your crypto to work",
                comment: "subttile for Earn section on Dashboard"
            )

            static let earnButtonTitle = NSLocalizedString("EARN", comment: "Title for Earn button on Dashboard")
        }

        static let rateAPY = NSLocalizedString(
            "APY",
            comment: "Acrynum for `Annual percentage yield`"
        )

        static let rewards = NSLocalizedString("%@ Rewards", comment: "Staking: %@ Rewards")
    }
}
