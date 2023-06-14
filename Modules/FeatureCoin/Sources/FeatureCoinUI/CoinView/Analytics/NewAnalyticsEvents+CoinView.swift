// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import FeatureCoinDomain

extension AnalyticsEvents.New {
    enum CoinViewAnalyticsEvent: AnalyticsEvent {

        var type: AnalyticsEventType { .nabu }

        case coinViewOpen(currency: String, origin: String)
        case coinViewClosed(currency: String)

        case chartEngaged(currency: String, timeInterval: String, origin: Origin = .coinView)
        case chartDisengaged(currency: String, timeInterval: String, origin: Origin = .coinView)
        case chartTimeIntervalSelected(currency: String, timeInterval: String, origin: Origin = .coinView)

        case buyReceiveClicked(currency: String, type: TransactionType, origin: Origin = .coinView)

        case explainerViewed(currency: String, accountType: AccountType, origin: Origin = .coinView)
        case explainerAccepted(currency: String, accountType: AccountType, origin: Origin = .coinView)

        case hyperlinkClicked(currency: String, selection: Selection, origin: Origin = .coinView)

        case transactionTypeClicked(
            currency: String,
            accountType: AccountType,
            transactionType: TransactionType,
            origin: Origin = .coinView
        )

        case walletsAccountsClicked(currency: String, accountType: AccountType, origin: Origin = .coinView)
        case walletsAccountsViewed(currency: String, accountType: AccountType, origin: Origin = .coinView)

        case connectToTheExchangeActioned(currency: String, origin: Origin = .coinView)

        case coinAddedToWatchlist(currency: String, origin: Origin = .coinView)
        case coinRemovedFromWatchlist(currency: String, origin: Origin = .coinView)

        enum Origin: String, StringRawRepresentable {
            case coinView = "COIN_VIEW"
        }

        enum Selection: String, StringRawRepresentable {
            case explorer = "EXPLORER"
            case learnMore = "LEARN_MORE"
            case officialWebsiteWeb = "OFFICIAL_WEBSITE_WEB"
            case viewLegal = "VIEW_LEGAL"
            case websiteWallet = "WEBSITE_WALLET"
            case whitePaper = "WHITE_PAPER"
        }

        enum TransactionType: String, StringRawRepresentable {
            case activity = "ACTIVITY"
            case add = "ADD"
            case buy = "BUY"
            case sell = "SELL"
            case receive = "RECEIVE"
            case send = "SEND"
            case deposit = "DEPOSIT"
            case rewardsSummary = "REWARDS_SUMMARY"
            case swap = "SWAP"
            case withdraw = "WITHDRAW"

            // swiftlint:disable cyclomatic_complexity
            init?(_ tag: Tag) {
                switch tag {
                case blockchain.ux.asset.account.activity:
                    self = .activity
                case blockchain.ux.asset.account.buy:
                    self = .buy
                case blockchain.ux.asset.account.receive:
                    self = .receive
                case blockchain.ux.asset.account.rewards.summary:
                    self = .rewardsSummary
                case blockchain.ux.asset.account.rewards.withdraw:
                    self = .withdraw
                case blockchain.ux.asset.account.rewards.deposit:
                    self = .add
                case blockchain.ux.asset.account.exchange.withdraw:
                    self = .withdraw
                case blockchain.ux.asset.account.exchange.deposit:
                    self = .deposit
                case blockchain.ux.asset.account.sell:
                    self = .sell
                case blockchain.ux.asset.account.send:
                    self = .send
                case blockchain.ux.asset.account.swap, blockchain.ux.asset.account.currency.exchange:
                    self = .swap
                default:
                    return nil
                }
            }
        }

        enum AccountType: String, StringRawRepresentable {
            case rewards = "REWARDS_ACCOUNT"
            case activeRewards = "EARN_CC1W"
            case trading = "CUSTODIAL"
            case userKey = "USERKEY"
            case exchange = "EXCHANGE_ACCOUNT"

            init(_ account: Account.Snapshot) {
                switch account.accountType {
                case .privateKey:
                    self = .userKey
                case .interest:
                    self = .rewards
                case .trading:
                    self = .trading
                case .exchange:
                    self = .exchange
                case .staking:
                    self = .rewards
                case .activeRewards:
                    self = .activeRewards
                }
            }
        }
    }
}

extension FeatureCoinDomain.Series {
    var analytics: String {
        switch self {
        case .now:
            return "LIVE"
        case .day:
            return "1D"
        case .week:
            return "1W"
        case .month:
            return "1M"
        case .year:
            return "1Y"
        case .all:
            return "ALL"
        default:
            return "NONE"
        }
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.CoinViewAnalyticsEvent) {
        record(event: event as AnalyticsEvent)
    }

    func record(events: [AnalyticsEvents.New.CoinViewAnalyticsEvent]) {
        record(events: events as [AnalyticsEvent])
    }
}
