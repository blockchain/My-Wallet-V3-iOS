@testable import BlockchainNamespace
import Combine
import FirebaseProtocol
import XCTest

final class AppTests: XCTestCase {

    var app: AppProtocol = App.test
    var count: [L: Int] = [:]

    var bag: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()

        app = App.test
        count = [:]

        let observations = [
            blockchain.session.event.will.sign.in,
            blockchain.session.event.did.sign.in,
            blockchain.session.event.will.sign.out,
            blockchain.session.event.did.sign.out,
            blockchain.ux.type.analytics.event
        ]

        for event in observations {
            app.on(event)
                .sink { _ in self.count[event, default: 0] += 1 }
                .store(in: &bag)
        }
    }

    func test_pub_sub() {

        app.post(event: blockchain.session.event.will.sign.in)
        app.post(event: blockchain.session.event.did.sign.in)
        app.post(event: blockchain.session.event.will.sign.out)
        app.post(event: blockchain.session.event.did.sign.out)

        XCTAssertEqual(count[blockchain.session.event.will.sign.in], 1)
        XCTAssertEqual(count[blockchain.session.event.did.sign.in], 1)
        XCTAssertEqual(count[blockchain.session.event.will.sign.out], 1)
        XCTAssertEqual(count[blockchain.session.event.did.sign.out], 1)

        XCTAssertEqual(count[blockchain.ux.type.analytics.event], 4)
    }

    func test_ref_no_id_then_update_when_session_value_arrives() throws {

        var token: String?
        let subscription = app.publisher(for: blockchain.user.token.firebase.installation, as: String.self)
            .sink { token = $0.value }
        addTeardownBlock(subscription.cancel)

        XCTAssertNil(token)

        app.state.set(blockchain.user["Oliver"].token.firebase.installation, to: "Token")

        XCTAssertNil(token)

        app.state.set(blockchain.user.id, to: "Oliver")

        XCTAssertEqual(token, "Token")
    }

    func test_action() {
        var count: Int = 0
        let subscription = app.on(blockchain.ui.type.action.then.launch.url) { _ in count += 1 }
            .subscribe()
        addTeardownBlock {
            subscription.cancel()
        }
        app.post(event: blockchain.ux.error.then.launch.url)
        XCTAssertEqual(count, 1)
    }

    func test_observer_to_ref() {

        var count: Int = 0
        let subscription = app.on(blockchain.db.collection["test"]) { _ in count += 1 }
            .subscribe()
        addTeardownBlock {
            subscription.cancel()
        }

        app.post(event: blockchain.db.collection["test"])
        XCTAssertEqual(count, 1)

        app.post(event: blockchain.db.collection)
        XCTAssertEqual(count, 1)
    }

    func test_set_get() async throws {

        app.signIn(userId: "Oliver")

        try await app.set(blockchain.user.email.address, to: "oliver@blockchain.com")
        let email: String = try await app.get(blockchain.user.email.address)

        XCTAssertEqual(email, "oliver@blockchain.com")
    }

    func test_set_and_execute_action() async throws {

        var enterInto: (story: Tag.Event?, promise: XCTestExpectation) = (nil, expectation(description: "enterInto story"))
        app.on(blockchain.ui.type.action.then.enter.into) { event in
            enterInto.story = try event.action?.data.as(Tag.Event.self)
            enterInto.promise.fulfill()
        }
        .subscribe()
        .tearDown(after: self)

        try await app.set(blockchain.ui.type.button.primary.tap.then.enter.into, to: blockchain.ux.asset["BTC"])
        app.post(event: blockchain.ui.type.button.primary.tap)

        await waitForExpectations(timeout: .seconds(0.1))

        XCTAssertEqual(enterInto.story?.key(to: [:]), blockchain.ux.asset["BTC"].key(to: [:]))
    }

    func test_nested_collection_data() async throws {

        try await app.set(
            blockchain.user["oliver"].wallet,
            to: [
                "bitcoin": ["is": ["funded": false]],
                "stellar": ["is": ["funded": true]]
            ]
        )

        try await app.set(blockchain.user["augustin"].wallet["bitcoin"], to: ["is": ["funded": true]])
        try await app.set(blockchain.user["augustin"].wallet["stellar"], to: ["is": ["funded": true]])

        try await app.set(blockchain.user["dimitris"].wallet["bitcoin"].is.funded, to: true)
        try await app.set(blockchain.user["dimitris"].wallet["stellar"].is.funded, to: false)

        do {
            let isFunded: Bool? = try? await app.get(blockchain.user.wallet["bitcoin"].is.funded)
            XCTAssertNil(isFunded)
        }

        do {
            let isFunded: Bool? = try? await app.get(blockchain.user["oliver"].wallet.is.funded)
            XCTAssertNil(isFunded)
        }

        do {
            let isFunded: Bool = try await app.get(blockchain.user["oliver"].wallet["bitcoin"].is.funded)
            XCTAssertFalse(isFunded)
        }

        do {
            let isFunded: Bool = try await app.get(blockchain.user["oliver"].wallet["stellar"].is.funded)
            XCTAssertTrue(isFunded)
        }

        do {
            let isFunded: Bool = try await app.get(blockchain.user["augustin"].wallet["bitcoin"].is.funded)
            XCTAssertTrue(isFunded)
        }

        do {
            let isFunded: Bool = try await app.get(blockchain.user["augustin"].wallet["stellar"].is.funded)
            XCTAssertTrue(isFunded)
        }

        do {
            let isFunded: Bool = try await app.get(blockchain.user["dimitris"].wallet["bitcoin"].is.funded)
            XCTAssertTrue(isFunded)
        }

        do {
            let isFunded: Bool = try await app.get(blockchain.user["dimitris"].wallet["stellar"].is.funded)
            XCTAssertFalse(isFunded)
        }
    }

    func test_local_store() async throws {

        let context: Tag.Context = [
            blockchain.ux.earn.portfolio.product.id: "staking",
            blockchain.ux.earn.portfolio.product.asset.id: "BTC"
        ]

        let key = blockchain.ux.earn.portfolio.product.asset.summary.add.paragraph.button.primary.tap.then.emit[].ref(
            to: context
        )

        let before = try await app.local.data.contains(key.route())
        XCTAssertFalse(before)

        let input = blockchain.ux.asset["BTC"].account["CryptoInterestAccount"].staking.deposit.key()
        let any: AnyHashable = input as AnyHashable
        try await app.set(key, to: any)

        let after = try await app.local.data.contains(key.route())
        XCTAssertTrue(after)

        let json: AnyJSON = try await app.get(key)
        let reference = try json.decode(Tag.Reference.self, using: BlockchainNamespaceDecoder())

        XCTAssertEqual(reference.string, input.string)

        let parent = blockchain.ux.earn.portfolio.product.asset.summary.add.paragraph.button.primary.tap[].ref(
            to: context
        )

        let parentExists = try await app.local.data.contains(parent.route())
        XCTAssertTrue(parentExists)
    }

    func test_napi() async throws {

        try await app.register(
            napi: blockchain.namespace.test.napi,
            domain: blockchain.namespace.test.napi.path,
            repository: { _ in .just(["to": ["value": "example"]]) }
        )

        try await app.register(
            napi: blockchain.namespace.test.napi,
            domain: blockchain.namespace.test.napi.path.to.collection.value,
            repository: { ref in
                .just(["string": ref.indices[blockchain.namespace.test.napi.path.to.collection.id] ?? "no"])
            }
        )

        await Task.megaYield()

        do {
            let (object, leaf) = try await (
                app.get(blockchain.namespace.test.napi.path.to, as: AnyJSON.self),
                app.get(blockchain.namespace.test.napi.path.to.value, as: AnyJSON.self)
            )
            try XCTAssertEqual(object.decode([String: String].self), ["value": "example"])
            try XCTAssertEqual(leaf.decode(String.self), "example")
        }

        do {
            let test = try await app.get(blockchain.namespace.test.napi.path.to.collection["test"].value.string, as: String.self)
            XCTAssertEqual(test, "test")
        }

        do {
            let id = UUID().uuidString
            let test = try await app.get(blockchain.namespace.test.napi.path.to.collection[id].value.string, as: String.self)
            XCTAssertEqual(test, id)
        }
    }

    func test_napi_price() async throws {

        app.state.set(blockchain.api.nabu.gateway.price.crypto.fiat.id, to: "GBP")

        try await app.register(
            napi: blockchain.api.nabu.gateway.price,
            domain: blockchain.api.nabu.gateway.price.crypto.fiat,
            repository: { tag in
                .just(
                     [
                         "quote": [
                             "value": [
                                 "amount": 1,
                                 "currency": tag.indices[blockchain.api.nabu.gateway.price.crypto.fiat.id] as Any
                             ]
                         ]
                     ]
                 )
            }
        )

        let money = try await app.get(blockchain.api.nabu.gateway.price.crypto["BTC"].fiat.quote.value, as: AnyJSON.self)

        XCTAssertEqual(money, ["amount": 1, "currency": "GBP"])
    }

    func test_napi_policy() async throws {

        var integers = (1..<100).makeIterator()

        try await app.register(
            napi: blockchain.namespace.test.napi,
            domain: blockchain.namespace.test.napi.path,
            repository: { _ in .just(["to": ["value": integers.next()]]) }
        )

        try await app.set(
            blockchain.namespace.test.napi.napi[blockchain.namespace.test.napi.path].policy.invalidate.on,
            to: blockchain.db.type.string[]
        )

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 1)
        }

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 1)
        }

        app.post(event: blockchain.db.type.string)

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 2)
        }

        app.post(event: blockchain.db.type.string)

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 3)
        }

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 3)
        }
    }

    func test_napi_policy_duration() async throws {

        let scheduler = DispatchQueue.test
        var integers = (1..<100).makeIterator()

        await app.napis.set(scheduler: scheduler.eraseToAnyScheduler())

        try await app.register(
            napi: blockchain.namespace.test.napi,
            domain: blockchain.namespace.test.napi.path,
            repository: { _ in .just(["to": ["value": integers.next()]]) }
        )

        try await app.set(
            blockchain.namespace.test.napi.napi[blockchain.namespace.test.napi.path].policy.invalidate.after.duration,
            to: TimeInterval.seconds(60)
        )

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 1)
        }

        await scheduler.advance(by: .seconds(30))

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 1)
        }

        await scheduler.advance(by: .seconds(30))

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 2)
        }

        await scheduler.advance(by: .seconds(60))

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 3)
        }

        await scheduler.advance(by: .seconds(30))

        do {
            let int = try await app.get(blockchain.namespace.test.napi.path.to.value, as: Int.self)
            XCTAssertEqual(int, 3)
        }
    }

    func test_napi_ref_counting() async throws {

        var integers = (1..<100).makeIterator()

        try await app.register(
            napi: blockchain.namespace.test.napi,
            domain: blockchain.namespace.test.napi.path,
            repository: { _ in
                .just(["to": ["value": integers.next()]])
            }
        )

        var seen = (false, false, false)

        let one = app.publisher(for: blockchain.namespace.test.napi.path.to.value, as: Int.self)
            .handleEvents(receiveOutput: { _ in seen.0 = true })
            .subscribe()

        let two = app.publisher(for: blockchain.namespace.test.napi.path.to.value, as: Int.self)
            .handleEvents(receiveOutput: { _ in seen.1 = true })
            .subscribe()

        let three = app.publisher(for: blockchain.namespace.test.napi.path.to.value, as: Int.self)
            .handleEvents(receiveOutput: { _ in seen.2 = true })
            .subscribe()

        while !(seen.0 && seen.1 && seen.2) { await Task.yield() }

        let domain = try await app.napis.roots[blockchain.namespace.test.napi[].as(blockchain.namespace.napi)]?.domains[blockchain.namespace.test.napi.path[]]

        do {
            let count = await domain?.count
            XCTAssertEqual(count, 3)
        }

        one.cancel()
        await Task.megaYield()

        do {
            let count = await domain?.count
            XCTAssertEqual(count, 2)
        }

        two.cancel()
        three.cancel()
        await Task.megaYield()

        do {
            let count = await domain?.count
            XCTAssertEqual(count, 0)
        }
    }

    func test_event_filtering() throws {
        var count = 0

        app.on(blockchain.ux.home["test"].tab.select) { _ in
            count += 1
        }
        .subscribe()
        .tearDown(after: self)

        XCTAssertEqual(count, 0)

        app.post(event: blockchain.ux.home["test"].tab["paulo"].select)
        XCTAssertEqual(count, 1)

        app.post(event: blockchain.ux.home["ignore"].tab["paulo"].select)
        XCTAssertEqual(count, 1)

        app.post(event: blockchain.ux.home["test"].tab["dimitris"].select)
        XCTAssertEqual(count, 2)
    }
}

final class AppActionTests: XCTestCase {

    var app: App.Test = App.test
    var count: Int { events.count }
    var events: [Session.Event] = []
    var bag: Set<AnyCancellable> = []
    var promise: XCTestExpectation!

    override func setUp() async throws {
        try await super.setUp()

        app = App.test
        events = []

        try await app.set(blockchain.ui.type.button.primary.tap.then.close, to: true)

        app.on(blockchain.ui.type.button.primary.tap.then.close) { [self] e in events.append(e) }
            .store(in: &bag)
    }

    func x_test_action_policy_perform_if() async throws {

        try await app.set(blockchain.ui.type.button.primary.tap.policy.perform.if, to: false)
        await app.post(event: blockchain.ui.type.button.primary.tap, context: [blockchain.db.type.string: "a"])

        try await app.wait(blockchain.ui.type.button.primary.tap.was.handled)

        XCTAssertEqual(count, 0)

        try await app.set(blockchain.ui.type.button.primary.tap.policy.perform.if, to: true)
        await app.post(event: blockchain.ui.type.button.primary.tap, context: [blockchain.db.type.string: "b"])

        try await app.wait(blockchain.ui.type.button.primary.tap.was.handled)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(events.last?.context[blockchain.db.type.string], "b")
    }

    func x_test_action_policy_discard_if() async throws {

        try await app.set(blockchain.ui.type.button.primary.tap.policy.discard.if, to: true)
        await app.post(event: blockchain.ui.type.button.primary.tap, context: [blockchain.db.type.string: "c"])
        try await app.wait(blockchain.ui.type.button.primary.tap.was.handled)

        XCTAssertEqual(count, 0)

        try await app.set(blockchain.ui.type.button.primary.tap.policy.discard.if, to: false)
        await app.post(event: blockchain.ui.type.button.primary.tap, context: [blockchain.db.type.string: "d"])
        try await app.wait(blockchain.ui.type.button.primary.tap.was.handled)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(events.last?.context[blockchain.db.type.string], "d")
    }

    func x_test_action_policy_perform_when() async throws {

        try await app.set(blockchain.ui.type.button.primary.tap.policy.perform.when, to: false)
        await app.post(event: blockchain.ui.type.button.primary.tap, context: [blockchain.db.type.string: "e"])

        XCTAssertEqual(count, 0)

        try await app.set(blockchain.ui.type.button.primary.tap.policy.perform.when, to: true)
        try await app.wait(blockchain.ui.type.button.primary.tap.was.handled)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(events.last?.context[blockchain.db.type.string], "e")
    }

    func x_test_action_policy_discard_when() async throws {

        try await app.set(blockchain.ui.type.button.primary.tap.policy.discard.when, to: false)
        await app.post(event: blockchain.ui.type.button.primary.tap, context: [blockchain.db.type.string: "f"])

        XCTAssertEqual(count, 0)

        try await app.set(blockchain.ui.type.button.primary.tap.policy.discard.when, to: true)
        try await app.wait(blockchain.ui.type.button.primary.tap.was.handled)

        XCTAssertEqual(count, 1)
        XCTAssertEqual(events.last?.context[blockchain.db.type.string], "f")
    }
}

extension App {

    public convenience init(
        language: Language = Language.root.language,
        state: Tag.Context = [:],
        remote: [Mock.RemoteConfigurationSource: [String: Mock.RemoteConfigurationValue]] = [:]
    ) {
        self.init(
            language: language,
            events: .init(),
            state: .init(state),
            remoteConfiguration: Session.RemoteConfiguration(remote: Mock.RemoteConfiguration(remote))
        )
    }
}
