@testable import BlockchainNamespace
import Combine
import KeychainKit
import XCTest

final class SessionObserverTests: XCTestCase {

    var app: AppProtocol = App.test

    var the: (
        notification: BlockchainEventSubscription,
        bindings: BlockchainEventSubscription,
        context: BlockchainEventSubscription
    )!

    override func setUp() {
        super.setUp()

        the = (
            app.on(blockchain.app.dynamic["event"].ux.action).start(),
            app.on(blockchain.app.dynamic["user"].ux.action).start(),
            app.on(blockchain.app.dynamic["ctx-action"].ux.action).start()
        )

        app.remoteConfiguration.override(
            blockchain.session.state.observers,
            with: [
                [
                    "event": [
                        "tag": blockchain.app.dynamic["test"].ux.analytics.event(\.string),
                        "notification": true
                    ] as [String: Any],
                    "action": blockchain.app.dynamic["event"].ux.action(\.string)
                ] as [String: Any],
                [
                    "event": [
                        "tag": blockchain.user.id,
                        "binding": true
                    ] as [String: Any],
                    "action": blockchain.app.dynamic["user"].ux.action(\.string)
                ] as [String: Any],
                [
                    "event": [
                        "tag": blockchain.app.dynamic["ctx-event"].ux.analytics.event(\.string),
                        "notification": true,
                        "context": [
                            blockchain.app.dynamic.id(\.id): "ctx-action"
                        ]
                    ] as [String: Any],
                    "action": blockchain.app.dynamic.ux.action(\.id)
                ] as [String: Any]
            ] as [Any]
        )
    }

    func test() {

        XCTAssertEqual(the.notification.count, 0)
        XCTAssertEqual(the.bindings.count, 0)
        XCTAssertEqual(the.context.count, 0)

        app.signIn(userId: "Dorothy")

        XCTAssertEqual(the.notification.count, 0)
        XCTAssertEqual(the.bindings.count, 1)
        XCTAssertEqual(the.context.count, 0)

        app.post(event: blockchain.app.dynamic["test"].ux.analytics.event)

        XCTAssertEqual(the.notification.count, 1)
        XCTAssertEqual(the.bindings.count, 1)
        XCTAssertEqual(the.context.count, 0)

        app.post(event: blockchain.app.dynamic["test"].ux.analytics.event)

        XCTAssertEqual(the.notification.count, 2)
        XCTAssertEqual(the.bindings.count, 1)
        XCTAssertEqual(the.context.count, 0)

        app.post(event: blockchain.app.dynamic["ctx-event"].ux.analytics.event)

        XCTAssertEqual(the.notification.count, 2)
        XCTAssertEqual(the.bindings.count, 1)
        XCTAssertEqual(the.context.count, 1)
    }
}
