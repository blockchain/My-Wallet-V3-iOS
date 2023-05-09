@testable import BlockchainNamespace
import Combine
import Extensions
import FirebaseProtocol
import XCTest

@available(iOS 15.0, macOS 12.0, *) // Replace with `async()` API when merged
final class SessionRemoteConfigurationTests: XCTestCase {

    var preferences: Mock.UserDefaults!
    var app: AppProtocol!
    var session: ImmediateURLSession!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()

        scheduler = DispatchQueue.test

        preferences = Mock.UserDefaults()
        preferences.set(
            [
                blockchain.app.configuration.manual.login.is.enabled(\.id): false
            ],
            forKey: blockchain.session.configuration(\.id)
        )
        session = URLSession.test
        session.data = Data(
            """
            {
                "experiment-1": 0,
                "experiment-2": 2
            }
            """.utf8
        )
        app = App(
            remoteConfiguration: Session.RemoteConfiguration(
                remote: Mock.RemoteConfiguration(
                    [
                        .remote: [
                            "ios_app_maintenance": true,
                            "ios_ff_apple_pay": true,
                            "ios_ff_app_superapp": true,
                            "blockchain_app_configuration_announcements": ["1", "2", "3"],
                            "blockchain_app_configuration_deep_link_rules": [],
                            "blockchain_app_configuration_customer_support_is_enabled": [
                                "{returns}": [
                                    "experiment": [
                                        "experiment-1": [
                                            "0": true,
                                            "1": false
                                        ]
                                    ]
                                ]
                            ],
                            "blockchain_app_configuration_customer_support_url": [
                                "{returns}": [
                                    "experiment": [
                                        "experiment-2": [
                                            "0": "https://support.blockchain.com?group=0",
                                            "1": "https://support.blockchain.com?group=1",
                                            "2": "https://support.blockchain.com?group=2"
                                        ]
                                    ]
                                ],
                                "default": "https://support.blockchain.com?group=default"
                            ],
                            "blockchain_ux_onboarding_promotion_cowboys_verify_identity_announcement": [
                                "title": "Cowboys Promotion",
                                "message": [
                                    "{returns}": [
                                        "experiment": [
                                            "experiment-1": [
                                                "0": "Message 1",
                                                "1": "Message 2"
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            "blockchain_ux_asset_ETH_account_CryptoStakingAccount_ETH_coming_soon_visit_learn_more_url":
                                "https://www.blockchain.com/coming_soon"
                        ]
                    ]
                ),
                session: session,
                preferences: preferences,
                scheduler: scheduler.eraseToAnyScheduler()
            )
        )
    }

    func test_fetch() async throws {

        let announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: [String].self)
            .await()
            .get()

        XCTAssertEqual(announcements, ["1", "2", "3"])

        try XCTAssertEqual(app.remoteConfiguration.get(blockchain.app.configuration.announcements), ["1", "2", "3"])
    }

    func test_fetch_with_underscore() async throws {
        let rules: [App.DeepLink.Rule] = try await app.publisher(for: blockchain.app.configuration.deep_link.rules)
            .await()
            .get()
        XCTAssertEqual(rules, [])
    }

    func test_fetch_fallback() async throws {

        let isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .await()
            .get()

        XCTAssertTrue(isEnabled)
    }

    func test_fetch_fallback_alternative() async throws {

        let isEnabled = try await app.publisher(for: blockchain.app.configuration.app.maintenance, as: Bool.self)
            .await()
            .get()

        XCTAssertTrue(isEnabled)
    }

    func test_fetch_type_mismatch() async throws {

        let announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: Bool.self)
            .await()

        XCTAssertThrowsError(try announcements.get())
    }

    func test_fetch_missing_value() async throws {

        let announcements = try await app.publisher(for: blockchain.user.email.address, as: String.self)
            .await()

        XCTAssertThrowsError(try announcements.get())
    }

    func test_fetch_then_override() async throws {

        var announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: [String].self)
            .await()
            .get()

        XCTAssertEqual(announcements, ["1", "2", "3"])

        app.remoteConfiguration.override(blockchain.app.configuration.announcements, with: ["4", "5", "6"])

        announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: [String].self)
            .await()
            .get()

        XCTAssertEqual(announcements, ["4", "5", "6"])
    }

    func test_all_keys() async throws {

        try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .await()

        XCTAssertEqual(
            app.remoteConfiguration.allKeys.set,
            [
                "ios_app_maintenance",
                "ios_ff_apple_pay",
                "ios_ff_app_superapp",
                "!blockchain.app.configuration.manual.login.is.enabled",
                "blockchain_app_configuration_announcements",
                "blockchain_app_configuration_deep_link_rules",
                "blockchain_app_configuration_customer_support_is_enabled",
                "blockchain_app_configuration_customer_support_url",
                "blockchain_ux_onboarding_promotion_cowboys_verify_identity_announcement",
                "blockchain_ux_asset_ETH_account_CryptoStakingAccount_ETH_coming_soon_visit_learn_more_url"
            ].set
        )
    }

    func test_key_with_id_with_full_stop() async throws {
        let url = try await app.get(
            blockchain.ux.asset["ETH"].account["CryptoStakingAccount.ETH"].coming.soon.visit.learn.more.url
        ) as String

        XCTAssertEqual(
            url,
            "https://www.blockchain.com/coming_soon"
        )
    }

    func test_with_default() async throws {

        let app = App(
            remoteConfiguration: .init(
                remote: Mock.RemoteConfiguration(),
                session: URLSession.test,
                preferences: Mock.Preferences(),
                scheduler: scheduler.eraseToAnyScheduler(),
                default: [
                    blockchain.app.configuration.apple.pay.is.enabled: true
                ]
            )
        )

        var isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .await()
            .get()

        XCTAssertTrue(isEnabled)

        XCTAssertEqual(
            app.remoteConfiguration.allKeys.set,
            ["blockchain.app.configuration.apple.pay.is.enabled"].set
        )

        app.remoteConfiguration.override(blockchain.app.configuration.apple.pay.is.enabled, with: false)

        isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .await()
            .get()

        XCTAssertEqual(
            app.remoteConfiguration.allKeys.set,
            [
                "blockchain.app.configuration.apple.pay.is.enabled",
                "!blockchain.app.configuration.apple.pay.is.enabled"
            ].set
        )

        XCTAssertFalse(isEnabled)

        app.remoteConfiguration.clear(blockchain.app.configuration.apple.pay.is.enabled)

        isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .await()
            .get()

        XCTAssertTrue(isEnabled)
    }

    func test_with_preferences() async throws {

        do {
            let isEnabled = try await app.publisher(
                for: blockchain.app.configuration.manual.login.is.enabled,
                as: Bool.self
            )
            .await()
            .get()

            XCTAssertFalse(isEnabled)
        }

        app.remoteConfiguration.override(blockchain.app.configuration.manual.login.is.enabled, with: true)

        do {
            let isEnabled = try await app.publisher(
                for: blockchain.app.configuration.manual.login.is.enabled,
                as: Bool.self
            )
            .await()
            .get()

            XCTAssertTrue(isEnabled)

            await scheduler.advance(by: .seconds(1))

            let preference = preferences.dictionary(
                forKey: blockchain.session.configuration(\.id)
            )?[blockchain.app.configuration.manual.login.is.enabled(\.id)]

            XCTAssertTrue(preference as? Bool == true)
        }
    }

    func test_fetch_superapp_feature_flag() async throws {
        let enabled = try await app.get(blockchain.app.configuration.app.superapp.is.enabled, as: Bool.self)
        XCTAssertTrue(enabled)
    }

    func test_experiment() async throws {

        let enabled = try await app.publisher(for: blockchain.app.configuration.customer.support.is.enabled, as: Bool.self).await().get()
        XCTAssertTrue(enabled)

        var url: URL = try await app.publisher(for: blockchain.app.configuration.customer.support.url).await().get()
        XCTAssertEqual(url, "https://support.blockchain.com?group=2")

        app.state.set(blockchain.ux.user.nabu.experiment["experiment-2"].group, to: 0)
        url = try await app.publisher(for: blockchain.app.configuration.customer.support.url).await().get()
        XCTAssertEqual(url, "https://support.blockchain.com?group=0")

        app.state.set(blockchain.ux.user.nabu.experiment["experiment-2"].group, to: 1)
        url = try await app.publisher(for: blockchain.app.configuration.customer.support.url).await().get()
        XCTAssertEqual(url, "https://support.blockchain.com?group=1")

        app.state.set(blockchain.ux.user.nabu.experiment["experiment-2"].group, to: 666)
        url = try await app.publisher(for: blockchain.app.configuration.customer.support.url).await().get()
        XCTAssertEqual(url, "https://support.blockchain.com?group=default")

        struct Announcement: Decodable {
            let title: String
            let message: String
        }

        var announcement = try await app.publisher(
            for: blockchain.ux.onboarding.promotion.cowboys.verify.identity.announcement,
            as: Announcement.self
        )
        .await()
        .get()

        XCTAssertEqual(announcement.message, "Message 1")

        app.state.set(blockchain.ux.user.nabu.experiment["experiment-1"].group, to: 1)
        announcement = try await app.publisher(
            for: blockchain.ux.onboarding.promotion.cowboys.verify.identity.announcement,
            as: Announcement.self
        )
        .await()
        .get()
        XCTAssertEqual(announcement.message, "Message 2")
    }

    func test_concurrency() async throws {
        let limit = 10

        DispatchQueue.concurrentPerform(iterations: limit) { i in
            app.remoteConfiguration.override(blockchain.db.collection[String(i)], with: i)
        }

        let results = try await (0..<limit).map { i in
            app.remoteConfiguration.publisher(for: blockchain.db.collection[String(i)]).decode(Int.self).map(\.value)
        }
        .combineLatest()
        .await()

        for i in 0..<limit {
            try XCTAssertEqual(app.remoteConfiguration.get(blockchain.db.collection[String(i)]), i)
        }
        XCTAssertNotNil(results)
    }
}
