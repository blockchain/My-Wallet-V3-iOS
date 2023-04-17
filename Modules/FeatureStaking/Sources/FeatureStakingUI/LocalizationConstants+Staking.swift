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

        enum InfoSheet {
            enum Rate {
                static let title = NSLocalizedString(
                    "Estimated annual rate",
                    comment: "Active Rewards: Rate Info Title"
                )
                static let description = NSLocalizedString(
                    "Rate perceived by the user if market price is at or lower than the trigger price at the expiration date.",
                    comment: "Active Rewards: Rate Info Description"
                )
            }

            enum Earnings {
                static let title = NSLocalizedString(
                    "Net earnings",
                    comment: "Active Rewards: Earnings Info Title"
                )
                static let description = NSLocalizedString(
                    "Sum of all debits and credits of previous strategies.",
                    comment: "Active Rewards: Earnings Info Description"
                )
            }

            enum OnHold {
                static let title = NSLocalizedString(
                    "On hold",
                    comment: "Active Rewards: OnHold Info Title"
                )
                static let description = NSLocalizedString(
                    "Funds you transfer during the week will be included in the following week's strategy at 08:00 AM (UTC).",
                    comment: "Active Rewards: OnHold Info Description"
                )
            }

            enum Trigger {
                static let title = NSLocalizedString(
                    "Trigger price",
                    comment: "Active Rewards: Trigger Info Title"
                )
                static let description = NSLocalizedString(
                    "A price level that results in a debit to your crypto balance if exceeded on the expiration date.",
                    comment: "Active Rewards: Trigger Info Description"
                )
            }
        }
    }

    enum PassiveRewards {

        enum InfoSheet {
            enum Rate {
                static let title = NSLocalizedString(
                    "Rewards rate",
                    comment: "Passive Rewards: Rate Info Title"
                )
                static let description = NSLocalizedString(
                    "Rewards accrues daily and is paid monthly. The rewards rate may be periodically adjusted.",
                    comment: "Passive Rewards: Rate Info Description"
                )
            }

            enum MonthlyEarnings {
                static let title = NSLocalizedString(
                    "Accrued this month",
                    comment: "Passive Rewards: MonthlyEarnings Info Title"
                )
                static let description = NSLocalizedString(
                    "Rewards earned month to date.",
                    comment: "Passive Rewards: MonthlyEarnings Info Description"
                )
            }

            enum HoldPeriod {
                static let title = NSLocalizedString(
                    "Initial hold period",
                    comment: "Passive Rewards: HoldPeriod Info Title"
                )
                static let description = NSLocalizedString(
                    "From the moment you deposit your funds into your Passive Rewards account, these will be restricted from being withdrawn for 7 days.",
                    comment: "Passive Rewards: HoldPeriod Info Description"
                )
            }

            enum Frequency {
                static let title = NSLocalizedString(
                    "Payment frequency",
                    comment: "Passive Rewards: Frequency Info Title"
                )
                static let description = NSLocalizedString(
                    "Rewards are paid by the end of the day on the 1st of each month.",
                    comment: "Passive Rewards: Frequency Info Description"
                )
            }
        }
    }

    enum Staking {

        static let title = NSLocalizedString("Staking Considerations", comment: "Title for Staking Considerations")

        static let page = NSLocalizedString(
                """
                Your staked ETH will start generating rewards after an initial bonding period.

                Unstaking and withdrawing ETH is subject to an unbonding period that depends on the network queue.

                These rules are not specific to Blockchain.com. They’re features of the Ethereum network.
                """,
                comment: "Staking: Explain to users their funds will be locked when staking their balance, until ETH implements withdraw. Page 1 of 3"
        )

        enum PendingWithdrawal {
            static let sectionTitle = NSLocalizedString("Pending Activity", comment: "Pending Activity")
            static let inProcess = NSLocalizedString("In process", comment: "Staking: In process")
            static let activeTitle = NSLocalizedString("Withdrew all %@", comment: "Staking: Withdrew all [CRYPTO]")
            static let title = NSLocalizedString("Withdrew %@", comment: "Staking: Withdrew [CRYPTO]")
            static let unbonding = NSLocalizedString("Unbonding", comment: "Staking: Unbonding")
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
        static let totalBalance = NSLocalizedString("Total Balance", comment: "Earn: Total Balance")
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
        static let estimatedAnnualRate = NSLocalizedString("Estimated annual rate", comment: "Staking: Estimated annual rate")
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
        static let gotIt = NSLocalizedString("Got It", comment: "Staking: Got It button")
        static let learningStaking = NSLocalizedString("Daily rewards for securing networks.", comment: "Staking: Daily rewards for securing networks.")
        static let learningSavings = NSLocalizedString("Monthly rewards for holding crypto with us.", comment: "Staking: Monthly rewards for holding crypto with us.")
        static let learningActive = NSLocalizedString("Earn rewards on crypto by subscribing to our strategy.", comment: "Staking: Active rewards description")
        static let learningDefault = NSLocalizedString("Read more on our new offering %@ Rewards.", comment: "Staking: Read more on our new offering %@ Rewards.")
        static let accruedThisMonth = NSLocalizedString("Accrued this month", comment: "Staking: Accrued this month")
        static let initialHoldPeriod = NSLocalizedString("Initial hold period", comment: "Staking: Initial hold period")
        static let initialHoldPeriodDuration = NSLocalizedString("%@ days", comment: "Staking: %@ days")
        static let nextPayment = NSLocalizedString("Next payment", comment: "Staking: Next payment")

        enum InfoSheet {
            enum Rate {
                static let title = NSLocalizedString(
                    "Current rate",
                    comment: "Staking: Rate Info Title"
                )
                static let description = NSLocalizedString(
                    "Rates are determined by each protocol minus a Blockchain.com fee. Users receive the displayed rate.",
                    comment: "Staking: Rate Info Description"
                )
            }
        }
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

        enum Compare {
            static let title = NSLocalizedString("Compare Products", comment: "Earn: Compare products")
            static let subtitle = NSLocalizedString("Learn which Earn Product is best for you.", comment: "Earn: Learn which product is best for you.")
            static let startEarningButton = NSLocalizedString("Start earning", comment: "Earn: Compare Start Earning button")
            static let go = NSLocalizedString("GO", comment: "Earn: Compare GO button")

            enum Passive {
                static let description = NSLocalizedString("Earn rewards for simply holding an asset for a longer period of time.", comment: "Earn: Compare Passive description")

                enum Items {
                    static let users = NSLocalizedString("For all eligible users", comment: "Earn: Compare Passive Users")
                    static let assets = NSLocalizedString("All assets available", comment: "Earn: Compare Passive Assets")
                    static let rate = NSLocalizedString("Up to 10% annually", comment: "Earn: Compare Passive Rate title")
                    static let rateDescription = NSLocalizedString("Updated monthly", comment: "Earn: Compare Passive Rate description")
                    static let periodicity = NSLocalizedString("Earn daily", comment: "Earn: Compare Passive Periodicity")
                    static let payment = NSLocalizedString("Paid monthly", comment: "Earn: Compare Passive Payment")
                    static let withdrawal = NSLocalizedString("Withdraw instantly after 7 days", comment: "Earn: Compare Passive Withdrawal")
                }
            }

            enum Staking {
                static let description = NSLocalizedString("Earn rewards by holding an asset and securing networks.", comment: "Earn: Compare Staking description")

                enum Items {
                    static let users = NSLocalizedString("Intermediate users", comment: "Earn: Compare Staking Users")
                    static let assets = NSLocalizedString("Ethereum", comment: "Earn: Compare Staking Assets")
                    static let rate = NSLocalizedString("Up to 4% annually", comment: "Earn: Compare Staking Rate title")
                    static let rateDescription = NSLocalizedString("Variable by network", comment: "Earn: Compare Staking Rate description")
                    static let periodicity = NSLocalizedString("Earn daily", comment: "Earn: Compare Staking Periodicity")
                    static let payment = NSLocalizedString("Paid daily", comment: "Earn: Compare Staking Payment")
                    static let withdrawal = NSLocalizedString("Withdraw depending on network", comment: "Earn: Compare Staking Withdrawal")
                }
            }

            enum Active {
                static let description = NSLocalizedString("Earn rewards by holding an asset and forecasting the market.", comment: "Earn: Compare Active description")

                enum Items {
                    static let users = NSLocalizedString("Advanced users", comment: "Earn: Compare Active Users")
                    static let assets = NSLocalizedString("Available on Bitcoin", comment: "Earn: Compare Active Assets")
                    static let rate = NSLocalizedString("Up to 8% annually", comment: "Earn: Compare Active Rate title")
                    static let rateDescription = NSLocalizedString("Variable weekly", comment: "Earn: Compare Active Rate description")
                    static let periodicity = NSLocalizedString("Earn weekly", comment: "Earn: Compare Active Periodicity")
                    static let payment = NSLocalizedString("Paid weekly", comment: "Earn: Compare Active Payment")
                    static let withdrawal = NSLocalizedString("Withdraw weekly", comment: "Earn: Compare Active Withdrawal")
                }
            }
        }
    }
}
