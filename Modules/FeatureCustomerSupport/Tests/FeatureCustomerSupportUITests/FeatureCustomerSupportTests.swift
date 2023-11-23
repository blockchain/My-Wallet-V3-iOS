import BlockchainNamespace
@testable import FeatureCustomerSupportUI
import XCTest

final class FeatureCustomerSupportTests: XCTestCase {

    var app: AppProtocol!
    var sut: CustomerSupportObserver<Test.Intercom>!
    var sdk: Test.Intercom.Type = Test.Intercom.self
    var url: URL?

    override func setUp() async throws {
        try await super.setUp()
        app = App.test
        try await app.register(
            napi: blockchain.api.nabu.gateway.user,
            domain: blockchain.api.nabu.gateway.user.intercom.identity.user.digest,
            repository: { _ async -> AnyJSON in "digest" }
        )
        sut = CustomerSupportObserver(
            app: app,
            scheduler: .immediate,
            apiKey: "api-key",
            appId: "app-id",
            open: { self.url = $0 },
            unreadNotificationName: .init(rawValue: "unreadNotificationName")
        )
        sut.start()
    }

    override func tearDown() {
        sut.stop()
        sut = nil
        app = nil
        Test.Intercom.tearDown()
        super.tearDown()
    }

    func test_api_key_is_initialised_on_start() throws {
        XCTAssertEqual(sdk.apiKey, "api-key")
        XCTAssertEqual(sdk.appId, "app-id")
    }

    func test_sign_in() async throws {

        let signIn = expectation(description: "signIn")

        Test.Intercom.signInExpectation = signIn
        app.signIn(userId: "user-id")
        app.state.set(blockchain.user.email.address, to: "oliver@blockchain.com")

        await fulfillment(of: [signIn])

        XCTAssertTrue(sdk.did.login)
        XCTAssertEqual(sdk.attributes.userId, "user-id")
        XCTAssertEqual(sdk.attributes.email, "oliver@blockchain.com")
        XCTAssertEqual(sdk.digest, "digest")
    }

    func test_sign_out() {
        app.signOut()
        XCTAssertTrue(sdk.did.logout)
    }

    func test_present_fallback_url() {
        app.post(event: blockchain.ux.customer.support.show.help.center)
        XCTAssertFalse(sdk.did.present)
        XCTAssertEqual(url?.absoluteString, "https://support.blockchain.com")
    }

    func test_present_fallback_url_from_config() {
        app.remoteConfiguration.override(
            blockchain.app.configuration.customer.support.url,
            with: "https://test.blockchain.com"
        )
        app.post(event: blockchain.ux.customer.support.show.help.center)
        XCTAssertEqual(url?.absoluteString, "https://test.blockchain.com")
    }

    func test_present_messenger() {
        app.remoteConfiguration.override(blockchain.app.configuration.customer.support.is.enabled, with: true)
        app.post(event: blockchain.ux.customer.support.show.help.center)
        XCTAssertTrue(sdk.did.present)
    }
}

enum Test {

    class Intercom: Intercom_p {

        static var apiKey, appId, digest: String!
        static var attributes: UserAttributes!
        static var signInExpectation: XCTestExpectation?

        static var did = (
            present: false,
            login: false,
            logout: false
        )

        static func tearDown() {
            apiKey = nil
            appId = nil
            attributes = nil
            digest = nil
            did = (false, false, false)
        }

        static func setApiKey(_ key: String, forAppId: String) {
            apiKey = key
            appId = forAppId
        }

        static func setUserHash(_ digest: String) {
            self.digest = digest
        }

        static func loginUser(with attributes: UserAttributes, completion: ((Result<Void, Error>) -> Void)?) {
            Self.attributes = attributes
            did.login = true
            completion?(.success(()))
            signInExpectation?.fulfill()
        }

        static func logout() {
            did.logout = true
        }

        static func showHelpCenter() {
            did.present = true
        }

        static func showMessenger() {
            did.present = true
        }

        static func unreadConversationCount() -> UInt {
            0
        }

        static func hide() {
            fatalError("unimplemented")
        }

        static func logEvent(withName name: String) {
            fatalError("unimplemented")
        }

        static func logEvent(withName name: String, metaData: [AnyHashable: Any]) {
            fatalError("unimplemented")
        }
    }

    class UserAttributes: IntercomUserAttributes_p {
        var userId: String?
        var email: String?
        var languageOverride: String?
        required init() {}
    }
}
