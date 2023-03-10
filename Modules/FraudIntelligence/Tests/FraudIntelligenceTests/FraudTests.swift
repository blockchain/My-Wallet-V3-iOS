import BlockchainNamespace
@testable import FraudIntelligence
import XCTest

final class FraudIntelligenceTests: XCTestCase {

    var app: AppProtocol!
    var sut: Sardine<Test.MobileIntelligence>!

    override func setUp() {
        super.setUp()
        app = App.debug(scheduler: .immediate)
        app.state.set(blockchain.ux.transaction.id, to: "buy")
        sut = Sardine(app, http: URLSession.test, scheduler: .immediate)
        sut.uuid = { "session-id" }
        sut.start()
    }

    override func tearDown() {
        sut.stop()
        Test.MobileIntelligence.tearDown()
        super.tearDown()
    }

    func initialise() {
        app.post(event: blockchain.app.did.finish.launching)
        app.remoteConfiguration.override(blockchain.app.fraud.sardine.client.identifier, with: "31d83c7d-c869-4ebb-a667-b89ec31aeb4e")
    }

    func test_initialise() {

        initialise()

        XCTAssertNotNil(Test.MobileIntelligence.options, "options should be not nil")
        XCTAssertEqual(Test.MobileIntelligence.options?.clientId, "31d83c7d-c869-4ebb-a667-b89ec31aeb4e", "client-id should match")
        XCTAssertEqual(Test.MobileIntelligence.options?.sessionKey, "session-id".sha256())
    }

    func test_update() {

        initialise()
        
        app.state.set(blockchain.user.id, to: "user-id")
        app.state.set(blockchain.app.fraud.sardine.current.flow, to: "order")

        XCTAssertEqual(Test.MobileIntelligence.options?.userIdHash, "user-id".sha256())
        XCTAssertEqual(Test.MobileIntelligence.options?.flow, "order")
    }

    func test_flow() throws {

        do {
            initialise()
            app.state.transaction { state in
                state.set(blockchain.user.id, to: "user-id")
                state.set(blockchain.app.fraud.sardine.session, to: "session-id")
            }
        }

        let flows: [[String: Any]] = [
            [
                "name": "login",
                "event": blockchain.session.event.will.sign.in(\.id)
            ],
            [
                "name": "order",
                "event": blockchain.ux.transaction.event.did.start(\.id)
            ],
            [
                "name": "ach",
                "event": blockchain.ux.transaction.enter.amount,
                "start": [
                    "if": [blockchain.session.state.value(\.id)]
                ]
            ],
            [
                "name": "unsupported",
                "event": blockchain.ux.transaction.event.did.finish(\.id)
            ]
        ]

        let flow = { [state = app.state] in
            try state.get(blockchain.app.fraud.sardine.current.flow) as String
        }

        app.remoteConfiguration.override(blockchain.app.fraud.sardine.flow, with: flows)
        app.state.set(blockchain.app.fraud.sardine.supported.flows, to: [
            "login",
            "order",
            "ach"
        ])
        XCTAssertThrowsError(try flow())

        app.post(event: blockchain.session.event.will.sign.in)
        XCTAssertEqual(try flow(), "login")
        XCTAssertEqual(Test.MobileIntelligence.options?.flow, "login")

        app.post(event: blockchain.ux.transaction.event.did.start)
        XCTAssertEqual(try flow(), "order")
        XCTAssertEqual(Test.MobileIntelligence.options?.flow, "order")

        app.post(event: blockchain.ux.transaction.enter.amount)
        XCTAssertEqual(try flow(), "order")
        XCTAssertEqual(Test.MobileIntelligence.options?.flow, "order")

        app.state.set(blockchain.session.state.value, to: true)
        app.post(event: blockchain.ux.transaction.enter.amount)
        XCTAssertEqual(try flow(), "ach")
        XCTAssertEqual(Test.MobileIntelligence.options?.flow, "ach")

        app.post(event: blockchain.ux.transaction.event.did.finish)
        XCTAssertEqual(try flow(), "ach")
        XCTAssertEqual(Test.MobileIntelligence.options?.flow, "ach")
    }

    func test_trigger() throws {

        let triggers: [Tag.Event] = [
            blockchain.session.event.did.sign.in,
            blockchain.ux.transaction.event.did.finish
        ]

        app.remoteConfiguration.override(blockchain.app.fraud.sardine.trigger, with: triggers)

        var count = 0
        let subscription = app.on(blockchain.app.fraud.sardine.submit) { _ in count += 1 }
        subscription.start()
        defer { subscription.stop() }

        app.state.set(blockchain.app.fraud.sardine.current.flow, to: "TEST")

        app.post(event: blockchain.session.event.will.sign.in)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(Test.MobileIntelligence.count, 1)

        app.post(event: blockchain.session.event.did.sign.in)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(Test.MobileIntelligence.count, 2)

        app.post(event: blockchain.ux.transaction.event.did.finish)
        XCTAssertEqual(count, 3)
        XCTAssertEqual(Test.MobileIntelligence.count, 3)
    }
}

enum Test {

    class MobileIntelligence: MobileIntelligence_p {

        static var options: Options?
        static var count: Int = 0

        static var field: [String: (focus: Bool, text: String)] = [:]

        static func tearDown() {
            options = nil
            count = 0
        }

        static func start(withOptions options: Options) -> AnyObject {
            Self.count = 0
            Self.options = options
            return MobileIntelligence()
        }

        static func submitData(completion: @escaping ((Response) -> Void)) {
            count += 1
            completion(Response(status: true, message: nil))
        }

        static func updateOptions(options: UpdateOptions, completion: ((Response) -> Void)?) {
            Self.options = Self.options ?? .init()
            Self.options?.sessionKey = options.sessionKey
            Self.options?.flow = options.flow
            Self.options?.userIdHash = options.userIdHash
            completion?(Response(status: true, message: nil))
        }

        static func trackField(forKey key: String, text: String) {
            var o = field[key, default: (false, "")]
            o.text = text
            field[key] = o
        }

        static func trackFieldFocus(forKey key: String, hasFocus: Bool) {
            var o = field[key, default: (false, "")]
            o.focus = hasFocus
            field[key] = o
        }
    }
}

extension Test.MobileIntelligence {

    struct Options: MobileIntelligenceOptions_p {

        var clientId: String?
        var sessionKey: String? {
            didSet {
                if let sessionKey { Self.last.sessionKey = sessionKey }
            }
        }
        var userIdHash: String?
        var environment: String?
        var flow: String? {
            didSet {
                if let flow { Self.last.flow = flow }
            }
        }
        var partnerId: String?
        var enableBehaviorBiometrics: Bool = false
        var enableClipboardTracking: Bool = false
        var enableFieldTracking: Bool = false

        static var ENV_SANDBOX: String = "sandbox"
        static var ENV_PRODUCTION: String = "production"

        static var last = (
            sessionKey: "",
            flow: ""
        )
    }

    struct UpdateOptions: MobileIntelligenceUpdateOptions_p {

        var userIdHash: String?
        var sessionKey: String
        var flow: String

        init() {
            self.sessionKey = Test.MobileIntelligence.Options.last.sessionKey
            self.flow = Test.MobileIntelligence.Options.last.flow
        }
    }

    struct Response: MobileIntelligenceResponse_p {
        var status: Bool?
        var message: String?
    }
}
