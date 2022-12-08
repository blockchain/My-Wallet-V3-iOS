import Foundation
import enum Localization.LocalizationConstants

// swiftlint:disable line_length

extension LocalizationConstants {

    enum Staking {

        static let title = NSLocalizedString("Staking Considerations", comment: "Title for Staking Considerations")

        static let page = (
            NSLocalizedString(
                """
                Your staked ETH will start generating rewards after an initial bonding period.

                While unstaking and withdrawing ETH isn’t currently available, it will be supported in a future upgrade.

                These rules are not specific to Blockchain.com. They’re features of the Ethereum network.
                """,
                comment: "Staking: Explain to users their funds will be locked when staking their balance, until ETH implements withdraw. Page 1 of 3"
            ),
            NSLocalizedString(
                """
                Once staked, ETH funds can’t be unstaked or transferred for an unspecified period of time.

                This may be up to 6 - 12 months away, but could be even longer.

                Your ETH will also be subject to a bonding period of %@ before it generates rewards.
                """,
                comment: "Staking: Explain to users their funds will be locked when staking their balance, until ETH implements withdraw. Page 3 of 3"
            )
        )

        static let next = NSLocalizedString("Next", comment: "Staking: Next CTA on Disclaimer")
        static let understand = NSLocalizedString("I understand", comment: "Staking: I understand CTA on Disclaimer")
        static let learnMore = NSLocalizedString("Learn More", comment: "Staking: Learn More button on Disclaimer")
        static let withdraw = NSLocalizedString("Withdraw", comment: "Staking: Withdraw Button")
        static let add = NSLocalizedString("Add", comment: "Staking: Add Button")
        static let summaryTitle = NSLocalizedString("%@ %@ Rewards", comment: "Staking: Staking Rewards title")
        static let balance = NSLocalizedString("Balance", comment: "Staking: Balance")
        static let totalEarned = NSLocalizedString("Total Earned", comment: "Staking: Total Earned")
        static let totalStaked = NSLocalizedString("Total Staked", comment: "Staking: Total Staked")
        static let totalDeposited = NSLocalizedString("Total Deposited", comment: "Staking: Total Deposited")
        static let bonding = NSLocalizedString("Bonding", comment: "Staking: Bonding")
        static let currentRate = NSLocalizedString("Current Rate", comment: "Staking: Current Rate")
        static let paymentFrequency = NSLocalizedString("Payment Frequency", comment: "Staking: Payment Frequency")
        static let daily = NSLocalizedString("Daily", comment: "Staking: Daily")
        static let weekly = NSLocalizedString("Weekly", comment: "Staking: Weekly")
        static let monthly = NSLocalizedString("Monthly", comment: "Staking: Monthly")
        static let viewActivity = NSLocalizedString("View Activity", comment: "Staking: View Activity")
        static let inProcess = NSLocalizedString("In process", comment: "Staking: In process")
        static let withdrawDisclaimer = NSLocalizedString("Unstaking and withdrawing ETH will be available when enabled by the Ethereum network.", comment: "Staking: Disclaimer")
        static let all = NSLocalizedString("All", comment: "Staking: All")
        static let search = NSLocalizedString("Search", comment: "Staking: Search")
        static let noResults = NSLocalizedString("😔 No results", comment: "Staking: 😔 No results")
        static let reset = NSLocalizedString("Reset Filters", comment: "Staking: Reset Filters")
        static let earning = NSLocalizedString("Earning", comment: "Staking: Earning")
        static let discover = NSLocalizedString("Discover", comment: "Staking: Discover")
        static let rewards = NSLocalizedString("%@ Rewards", comment: "Staking: %@ Rewards")
        static let staking = NSLocalizedString("Staking", comment: "Staking: Staking")
        static let passive = NSLocalizedString("Passive", comment: "Staking: Passive")
        static let noBalanceTitle = NSLocalizedString("You don’t have any %@", comment: "Staking: You don’t have any %@")
        static let noBalanceMessage = NSLocalizedString("Buy or receive %@ to start earning", comment: "Staking: Buy or receive %@ to start earning")
        static let buy = NSLocalizedString("Buy %@", comment: "Staking: Buy")
        static let receive = NSLocalizedString("Receive %@", comment: "Staking: Receive")
        static let notEligibleTitle = NSLocalizedString("We’re not in your region yet", comment: "Staking: We’re not in your region yet")
        static let notEligibleMessage = NSLocalizedString("%@ Rewards for %@ are currently unavailable in your region.\n\nWe are working hard so that you get the most of all our products. We’ll let you know as soon as we can!", comment: "Staking: %@ Rewards for %@ are currently unavailable in your region.\n\nWe are working hard so that you get the most of all our products. We’ll let you know as soon as we can!")
        static let goBack = NSLocalizedString("Go Back", comment: "Staking: Go Back")
        static let learningStaking = NSLocalizedString("Daily rewards for securing networks.", comment: "Staking: Daily rewards for securing networks.")
        static let learningSavings = NSLocalizedString("Monthly rewards for holding crypto with us.", comment: "Staking: Monthly rewards for holding crypto with us.")
        static let learningDefault = NSLocalizedString("Read more on our new offering %@ Rewards.", comment: "Staking: Read more on our new offering %@ Rewards.")
    }
}
