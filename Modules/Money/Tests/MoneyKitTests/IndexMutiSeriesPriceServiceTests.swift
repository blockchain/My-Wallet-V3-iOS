import BlockchainNamespace
import CombineSchedulers
import Extensions
@testable import MoneyKit
import XCTest

// TODO:
// - use client over session

final class IndexMutiSeriesPriceServiceTests: XCTestCase {

    let BTC = CryptoCurrency.bitcoin
    let ETH = CryptoCurrency.ethereum
    let GBP = FiatCurrency.GBP
    let USD = FiatCurrency.USD

    var app: AppProtocol!
    var scheduler: TestSchedulerOf<DispatchQueue>!
    var session: URLSession!

    override func setUp() {
        super.setUp()
        app = App.test

        scheduler = DispatchQueue.test
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)

        MockURLProtocol.register(URLRequest("POST", "https://api.blockchain.info/price/index-multi-series")) { request in
            (
                request.ok,
                Data(
                    """
                    {
                        "BTC-USD": [
                            {
                                "price": 28877.5,
                                "timestamp": 1688031472
                            },
                            {
                                "price": 28879,
                                "timestamp": 1680192240
                            }
                        ]
                    }
                    """.utf8
                )
            )
        }
        MockURLProtocol.register(URLRequest("POST", "https://api.blockchain.info/price/index-multi")) { request in
            let now = Date()
            return (
                request.ok,
                Data(
                    """
                    {
                        "BTC-GBP": {
                            "price": 22877.5,
                            "timestamp": \(now.timeIntervalSince1970.i)
                        },
                        "ETH-USD": {
                            "price": 1446.6,
                            "timestamp": \(now.timeIntervalSince1970.i)
                        }
                    }
                    """.utf8
                )
            )
        }
    }

    func test() async throws {

        let service = IndexMutiSeriesPriceService(
            app: app,
            session: session,
            scheduler: scheduler.eraseToAnyScheduler(),
            refreshInterval: .seconds(5),
            cancellingGracePeriod: .seconds(5)
        )

        let BTC_GBP = Task { for await _ in await service.stream(CurrencyPairAndTime(base: BTC, quote: GBP, time: nil)) { } }
        let ETH_USD = Task { for await _ in await service.stream(CurrencyPairAndTime(base: ETH, quote: USD, time: nil)) { } }
        let BTC_USD_YDAY = Task { for await _ in await service.stream(CurrencyPairAndTime(base: BTC, quote: USD, time: Date().addingTimeInterval(-.day))) { } }

        do {
            let isEmpty = await service.subscriptions.isEmpty
            XCTAssertTrue(isEmpty)
        }

        await scheduler.advance(by: .seconds(5))

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 3, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        _ = try await service.store.stream(CurrencyPairAndTime(base: BTC, quote: GBP, time: nil)).compacted()
            .next(timeout: .seconds(1), scheduler: DispatchQueue.main)

        BTC_USD_YDAY.cancel()

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 3, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        await scheduler.advance(by: .seconds(5))

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 2, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        ETH_USD.cancel()

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 2, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        await scheduler.advance(by: .seconds(5))

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 1, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        BTC_GBP.cancel()

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 1, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        await scheduler.advance(by: .seconds(5))

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 0, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }
    }

    func test_no_grace_period() async throws {

        let service = IndexMutiSeriesPriceService(
            app: app,
            session: session,
            scheduler: scheduler.eraseToAnyScheduler(),
            refreshInterval: .seconds(5),
            cancellingGracePeriod: .zero
        )

        let BTC_GBP = Task { for await _ in await service.stream(CurrencyPairAndTime(base: BTC, quote: GBP, time: nil)) { } }
        let ETH_USD = Task { for await _ in await service.stream(CurrencyPairAndTime(base: ETH, quote: USD, time: nil)) { } }
        let BTC_USD_YDAY = Task { for await _ in await service.stream(CurrencyPairAndTime(base: BTC, quote: USD, time: Date().addingTimeInterval(-.day))) { } }

        do {
            let isEmpty = await service.subscriptions.isEmpty
            XCTAssertTrue(isEmpty)
        }

        await scheduler.advance(by: .seconds(5))

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 3, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        _ = try await service.store.stream(CurrencyPairAndTime(base: BTC, quote: GBP, time: nil)).compacted()
            .next(timeout: .seconds(1), scheduler: DispatchQueue.main)

        BTC_USD_YDAY.cancel()
        await Task.megaYield(count: 100)

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 2, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        ETH_USD.cancel()
        await Task.megaYield(count: 100)

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 1, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }

        BTC_GBP.cancel()
        await Task.megaYield(count: 100)

        do {
            let subscriptions = await service.subscriptions
            XCTAssertEqual(subscriptions.count, 0, subscriptions.map(\.currencyPair.string).joined(separator: ", "))
        }
    }

    func test_refresh_interval() async throws {

        let service = IndexMutiSeriesPriceService(
            app: app,
            session: session,
            scheduler: scheduler.eraseToAnyScheduler(),
            refreshInterval: .seconds(5),
            cancellingGracePeriod: .zero
        )

        actor Counter {
            var count = 0
            func increment() { count += 1 }
        }

        let counter = Counter()

        Task {
            for await _ in await service.stream(CurrencyPairAndTime(base: BTC, quote: GBP, time: nil)) {
                await counter.increment()
            }
        }

        await Task.megaYield()
        await scheduler.advance(by: .seconds(1))
        _ = try await service.store.stream(CurrencyPairAndTime(base: BTC, quote: GBP, time: nil)).compacted()
            .next(timeout: .seconds(1), scheduler: DispatchQueue.main) // subscribe to the data at least once ...
        await Task.megaYield()

        do {
            let count = await counter.count
            XCTAssertEqual(count, 1)
        }

        await scheduler.advance(by: .seconds(5))
        await Task.megaYield(count: 100)

        do {
            let count = await counter.count
            XCTAssertEqual(count, 2)
        }

        await scheduler.advance(by: .seconds(15))
        await Task.megaYield(count: 100)

        do {
            let count = await counter.count
            XCTAssertEqual(count, 5)
        }
    }
}
