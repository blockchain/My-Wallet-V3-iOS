// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import FeatureCoinDomain
@testable import FeatureCoinUI
import XCTest

final class CoinViewAnalyticsObserverTests: XCTestCase {

    var app: App.Test!
    var analytics: AnalyticsEventRecorder!
    var sut: CoinViewAnalyticsObserver! {
        didSet { sut?.start() }
    }

    override func setUp() {
        super.setUp()
        app = App.test
        analytics = AnalyticsEventRecorder()
        sut = CoinViewAnalyticsObserver(app: app, analytics: analytics)
        app.state.set(blockchain.ux.asset["BTC"].select.origin, to: "TEST_ORIGIN")
    }

    override func tearDown() {
        sut.stop()
        super.tearDown()
    }

    func test_chart_selected() async {
        await app.post(
            event: blockchain.ux.asset["BTC"].chart.selected,
            context: [blockchain.ux.asset.chart.interval: Series.week]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_chart_deselected() async {
        await app.post(
            event: blockchain.ux.asset["BTC"].chart.deselected,
            context: [blockchain.ux.asset.chart.interval: Series.week]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_chart_interval() async {
        await app.post(value: Series.week, of: blockchain.ux.asset["BTC"].chart.interval)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_receive() async {
        await app.post(event: blockchain.ux.asset["BTC"].receive)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_explainer() async {
        await app.post(
            event: blockchain.ux.asset["BTC"].account["Trading"].explainer,
            context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_explainer_accept() async {
        await app.post(
            event: blockchain.ux.asset["BTC"].account["Trading"].explainer.accept,
            context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_website() async {
        await app.post(event: blockchain.ux.asset["BTC"].bio.visit.website)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_account_sheet() async {
        await app.post(
            event: blockchain.ux.asset["BTC"].account["Trading"].sheet,
            context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_exchange_connect() async {
        await app.post(event: blockchain.ux.asset["BTC"].account["Trading"].exchange.connect)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_transaction() async {

        let events: [Tag.Event] = [
            blockchain.ux.asset["BTC"].account["Trading"].activity,
            blockchain.ux.asset["BTC"].account["Trading"].buy,
            blockchain.ux.asset["BTC"].account["Trading"].receive,
            blockchain.ux.asset["BTC"].account["Trading"].rewards.summary,
            blockchain.ux.asset["BTC"].account["Trading"].rewards.withdraw,
            blockchain.ux.asset["BTC"].account["Trading"].rewards.deposit,
            blockchain.ux.asset["BTC"].account["Trading"].exchange.withdraw,
            blockchain.ux.asset["BTC"].account["Trading"].exchange.deposit,
            blockchain.ux.asset["BTC"].account["Trading"].sell,
            blockchain.ux.asset["BTC"].account["Trading"].send,
            blockchain.ux.asset["BTC"].account["Trading"].swap
        ]

        for event in events {
            await app.post(event: event, context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading])
        }

        XCTAssertEqual(analytics.session.count, events.count)
    }

    func test_watchlist() async {
        await app.post(event: blockchain.ux.asset["BTC"].watchlist.add)
        XCTAssertEqual(analytics.session.count, 1)
        await app.post(event: blockchain.ux.asset["BTC"].watchlist.remove)
        XCTAssertEqual(analytics.session.count, 2)
    }
}

class AnalyticsEventRecorder: AnalyticsEventRecorderAPI {
    var session: [AnalyticsEvent] = []
    func record(event: AnalyticsEvent) { session.append(event) }
}
