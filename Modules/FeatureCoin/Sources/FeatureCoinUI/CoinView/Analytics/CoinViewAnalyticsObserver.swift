// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import FeatureCoinDomain
import SwiftUI

public final class CoinViewAnalyticsObserver: Client.Observer {

    unowned var app: AppProtocol
    let analytics: AnalyticsEventRecorderAPI

    public init(app: AppProtocol, analytics: AnalyticsEventRecorderAPI) {
        self.app = app
        self.analytics = analytics
    }

    public func start() {
        for event in events {
            event.start()
        }
    }

    public func stop() {
        for event in events {
            event.stop()
        }
    }

    lazy var events: [BlockchainEventSubscription] = [
        chart,
        receive,
        explainer,
        website,
        chartInterval,
        transaction,
        accountSheet,
        exchangeConnect,
        watchlistAdd,
        watchlistRemove
    ]

    lazy var chart = app.on(
        blockchain.ux.asset.chart.selected,
        blockchain.ux.asset.chart.deselected
    ) { [analytics] event in
        guard let series = event.context[blockchain.ux.asset.chart.interval] as? FeatureCoinDomain.Series else {
            return
        }
        let currency = try event.reference.context.decode(blockchain.ux.asset.id) as String
        let timeInterval = series.analytics
        analytics.record(
            event: event.tag.is(blockchain.ux.asset.chart.selected)
                ? .chartEngaged(currency: currency, timeInterval: timeInterval)
                : .chartDisengaged(currency: currency, timeInterval: timeInterval)
        )
    }

    lazy var chartInterval = app.on(blockchain.ux.asset.chart.interval) { [analytics] event in
        guard let series = event.context[event.reference] as? FeatureCoinDomain.Series else {
            return
        }
        try analytics.record(
            event: .chartTimeIntervalSelected(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String,
                timeInterval: series.analytics
            )
        )
    }

    lazy var receive = app.on(blockchain.ux.asset.receive) { [analytics] event in
        try analytics.record(
            event: .buyReceiveClicked(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String,
                type: .receive
            )
        )
    }

    lazy var explainer = app.on(
        blockchain.ux.asset.account.explainer,
        blockchain.ux.asset.account.explainer.accept
    ) { [analytics] event in
        guard let account = event.context[blockchain.ux.asset.account] as? Account.Snapshot else { return }
        let accountType = AnalyticsEvents.New.CoinViewAnalyticsEvent.AccountType(account)
        let currency = try event.reference.context.decode(blockchain.ux.asset.id) as String
        analytics.record(
            event: event.tag.is(blockchain.ux.asset.account.explainer.accept)
                ? .explainerAccepted(currency: currency, accountType: accountType)
                : .explainerViewed(currency: currency, accountType: accountType)
        )
    }

    lazy var website = app.on(blockchain.ux.asset.bio.visit.website) { [analytics] event in
        try analytics.record(
            event: .hyperlinkClicked(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String,
                selection: .officialWebsiteWeb
            )
        )
    }

    lazy var transaction = app.on(
        blockchain.ux.asset.account.activity,
        blockchain.ux.asset.account.buy,
        blockchain.ux.asset.account.receive,
        blockchain.ux.asset.account.rewards.summary,
        blockchain.ux.asset.account.rewards.withdraw,
        blockchain.ux.asset.account.rewards.deposit,
        blockchain.ux.asset.account.exchange.withdraw,
        blockchain.ux.asset.account.exchange.deposit,
        blockchain.ux.asset.account.sell,
        blockchain.ux.asset.account.send,
        blockchain.ux.asset.account.swap,
        blockchain.ux.asset.account.currency.exchange,
        blockchain.ux.asset.account.currency.get.token
    ) { [analytics] event in
        guard let account = event.context[blockchain.ux.asset.account] as? Account.Snapshot else { return }
        print(account)

        guard let transaction = AnalyticsEvents.New.CoinViewAnalyticsEvent.TransactionType(event.tag) else { return }
        print(transaction)
        let accountType = AnalyticsEvents.New.CoinViewAnalyticsEvent.AccountType(account)
        try analytics.record(
            event: .transactionTypeClicked(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String,
                accountType: accountType,
                transactionType: transaction
            )
        )
    }

    lazy var accountSheet = app.on(blockchain.ux.asset.account.sheet) { [analytics] event in
        guard let account = event.context[blockchain.ux.asset.account] as? Account.Snapshot else { return }
        let currency = try event.reference.context.decode(blockchain.ux.asset.id) as String
        analytics.record(
            events: [
                .walletsAccountsClicked(currency: currency, accountType: .init(account)),
                .walletsAccountsViewed(currency: currency, accountType: .init(account))
            ]
        )
    }

    lazy var exchangeConnect = app.on(blockchain.ux.asset.account.exchange.connect) { [analytics] event in
        try analytics.record(
            event: .connectToTheExchangeActioned(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String
            )
        )
    }

    lazy var watchlistAdd = app.on(blockchain.ux.asset.watchlist.add) { [analytics] event in
        try analytics.record(
            event: .coinAddedToWatchlist(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String
            )
        )
    }

    lazy var watchlistRemove = app.on(blockchain.ux.asset.watchlist.remove) { [analytics] event in
        try analytics.record(
            event: .coinRemovedFromWatchlist(
                currency: event.reference.context.decode(blockchain.ux.asset.id) as String
            )
        )
    }
}
