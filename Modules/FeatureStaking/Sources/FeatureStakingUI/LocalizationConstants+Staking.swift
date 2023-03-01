import Foundation
import enum Localization.LocalizationConstants

extension LocalizationConstants {

    enum ActiveRewards {

        static let title = NSLocalizedString("Active Rewards Considerations", comment: "Title for Active Rewards Considerations")

        static let description = NSLocalizedString(
                """
                Price movements may result in a reduction of your asset’s balance.

                Once subscribed, assets are locked until the following week and subject to market volatility.

                Blockchain.com does not assume liability for any losses incurred from price fluctuations. Please trade with caution.
                """,
                comment: "AR: Explain to users their funds will be locked"
        )
    }

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

        enum PendingWithdrawal {
            static let inProcess = NSLocalizedString("In process", comment: "Staking: In process")
            static let title = NSLocalizedString("Withdraw all %@", comment: "Staking: Withdraw all [CRYPTO]")
            static let subtitle = NSLocalizedString("Requested", comment: "Staking: Requested")
            static let date = NSLocalizedString("Next Saturday", comment: "Staking: Next Saturday")
        }

        static let earn = NSLocalizedString("Earn", comment: "Staking: Earn title")
        static let next = NSLocalizedString("Next", comment: "Staking: Next CTA on Disclaimer")
        static let new = NSLocalizedString("NEW", comment: "Staking: NEW")
        static let understand = NSLocalizedString("I understand", comment: "Staking: I understand CTA on Disclaimer")
        static let learnMore = NSLocalizedString("Learn More", comment: "Staking: Learn More button on Disclaimer")
        static let withdraw = NSLocalizedString("Withdraw", comment: "Staking: Withdraw Button")
        static let important = NSLocalizedString("Important", comment: "Staking: Important")
        static let add = NSLocalizedString("Add", comment: "Staking: Add Button")
        static let summaryTitle = NSLocalizedString("%@ %@ Rewards", comment: "Staking: Staking Rewards title")
        static let balance = NSLocalizedString("Balance", comment: "Staking: Balance")
        static let price = NSLocalizedString("%@ Price", comment: "Staking: Crypto Price")
        static let netEarnings = NSLocalizedString("Net Earnings", comment: "Staking: Net Earnings")
        static let totalEarned = NSLocalizedString("Total Earned", comment: "Staking: Total Earned")
        static let totalStaked = NSLocalizedString("Total Staked", comment: "Staking: Total Staked")
        static let totalDeposited = NSLocalizedString("Total Deposited", comment: "Staking: Total Deposited")
        static let bonding = NSLocalizedString("Bonding", comment: "Staking: Bonding")
        static let onHold = NSLocalizedString("On hold", comment: "Staking: On hold")
        static let totalSubscribed = NSLocalizedString("Total Subscribed", comment: "Staking: Total Subscribed")
        static let triggerPrice = NSLocalizedString("Trigger Price", comment: "Staking: Trigger Price")
        static let currentRate = NSLocalizedString("Current Rate", comment: "Staking: Current Rate")
        static let paymentFrequency = NSLocalizedString("Payment Frequency", comment: "Staking: Payment Frequency")
        static let daily = NSLocalizedString("Daily", comment: "Staking: Daily")
        static let weekly = NSLocalizedString("Weekly", comment: "Staking: Weekly")
        static let monthly = NSLocalizedString("Monthly", comment: "Staking: Monthly")
        static let viewActivity = NSLocalizedString("View Activity", comment: "Staking: View Activity")
        static let inProcess = NSLocalizedString("In process", comment: "Staking: In process")
        static let stakingWithdrawDisclaimer = NSLocalizedString("Unstaking and withdrawing ETH will be available when enabled by the Ethereum network.", comment: "Staking: Disclaimer")
        static let activeWithdrawDisclaimer = NSLocalizedString("Blockchain.com does not assume liability for any losses incurred from price fluctuations. Please trade with caution.", comment: "AR: Disclaimer")
        static let all = NSLocalizedString("All", comment: "Staking: All")
        static let search = NSLocalizedString("Search", comment: "Staking: Search")
        static let searchCoin = NSLocalizedString("Search Coin", comment: "Staking: Search Coin")
        static let noResults = NSLocalizedString("😔 No results", comment: "Staking: 😔 No results")
        static let reset = NSLocalizedString("Reset Filters", comment: "Staking: Reset Filters")
        static let earning = NSLocalizedString("Earning", comment: "Staking: Earning")
        static let discover = NSLocalizedString("Discover", comment: "Staking: Discover")
        static let rewards = NSLocalizedString("%@ Rewards", comment: "Staking: %@ Rewards")
        static let staking = NSLocalizedString("Staking", comment: "Staking: Staking")
        static let passive = NSLocalizedString("Passive", comment: "Staking: Passive")
        static let active = NSLocalizedString("Active", comment: "Staking: Active")
        static let noBalanceTitle = NSLocalizedString("You don’t have any %@", comment: "Staking: You don’t have any %@")
        static let noBalanceMessage = NSLocalizedString("Buy or receive %@ to start earning", comment: "Staking: Buy or receive %@ to start earning")
        static let buy = NSLocalizedString("Buy %@", comment: "Staking: Buy")
        static let receive = NSLocalizedString("Receive %@", comment: "Staking: Receive")
        static let notEligibleTitle = NSLocalizedString("We’re not in your region yet", comment: "Staking: We’re not in your region yet")
        static let notEligibleMessage = NSLocalizedString("%@ Rewards for %@ are currently unavailable in your region.\n\nWe are working hard so that you get the most of all our products. We’ll let you know as soon as we can!", comment: "Staking: %@ Rewards for %@ are currently unavailable in your region.\n\nWe are working hard so that you get the most of all our products. We’ll let you know as soon as we can!")
        static let goBack = NSLocalizedString("Go Back", comment: "Staking: Go Back")
        static let learningStaking = NSLocalizedString("Daily rewards for securing networks.", comment: "Staking: Daily rewards for securing networks.")
        static let learningSavings = NSLocalizedString("Monthly rewards for holding crypto with us.", comment: "Staking: Monthly rewards for holding crypto with us.")
        static let learningActive = NSLocalizedString("Earn rewards on crypto by subscribing to our strategy.", comment: "Staking: Active rewards description")
        static let learningDefault = NSLocalizedString("Read more on our new offering %@ Rewards.", comment: "Staking: Read more on our new offering %@ Rewards.")
    }

    enum Earn {
        enum Intro {
            static let button = NSLocalizedString("Start Earning", comment: "Staking: Intro button")

            enum Intro {
                static let title = NSLocalizedString("Earn", comment: "Staking: Intro title")
                static let description = NSLocalizedString("Get the most out of your crypto.\nDeposit and earn up to 10%.", comment: "Staking: Intro description")
            }

            enum Passive {
                static let title = NSLocalizedString("Passive rewards", comment: "Staking: Intro Passive rewards title")
                static let description = NSLocalizedString("Get paid every month, just for holding.", comment: "Staking: Intro Passive rewards button")
            }

            enum Staking {
                static let title = NSLocalizedString("Staking rewards", comment: "Staking: Intro Staking title")
                static let description = NSLocalizedString("Earn crypto for securing your favorite blockchain networks.", comment: "Staking: Intro Staking description")
            }

            enum Active {
                static let title = NSLocalizedString("Active rewards", comment: "Staking: Intro Active title")
                static let description = NSLocalizedString("Participate on weekly strategies and earn rewards based on crypto performance.", comment: "Staking: Intro Active description")
            }
        }
    }
}
