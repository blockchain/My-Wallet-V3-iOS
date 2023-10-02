// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
@testable import FeatureOpenBankingDomain
@testable import FeatureOpenBankingUI
import NetworkKit
import TestKit

final class BankLinkTests: OpenBankingTestCase {

    typealias Store = TestStore<
        BankState,
        BankAction,
        BankState,
        BankAction,
        Void
    >

    private var store: Store!

    // swiftlint:disable:next force_try
    private lazy var update = try! network[
        URLRequest(.post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update")
    ]
    .unwrap()
    .decode(to: OpenBanking.BankAccount.self)

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = .init(
            initialState: initialState,
            reducer: BankReducer(environment: environment)
        )
    }

    var initialState: BankState {
        .init(data: .init(
            account: createAccount,
            action: .link(
                institution: institution
            )
        ))
    }

    func test_initial_state() throws {

        let state = initialState
        XCTAssertEqual(state.account, createAccount)
        XCTAssertEqual(state.name, "Monzo")
        XCTAssertNil(state.ui)
    }

    func test_request_and_wait_for_approval_with_failure() throws {

        network[
            URLRequest(.get, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c")
        ] = nil

        store.send(.request) { state in
            state.ui = .communicating(to: state.name)
        }

        scheduler.advance(by: .seconds(1))

        store.send(.failure(.timeout)) { state in
            state.ui = .pending()
            state.showActions = true
        }
        store.send(.cancel)
    }

    func test_request() throws {

        let url = try account.attributes.authorisationUrl.unwrap()

        store.send(.request) { state in
            state.ui = .communicating(to: state.name)
        }
        scheduler.advance()
        store.receive(.waitingForConsent) { state in
            state.ui = .waiting(for: state.name)
        }

        app.state.set(blockchain.ux.payment.method.open.banking.is.authorised, to: true)
        scheduler.advance()
        store.receive(.launchAuthorisation(url))
        store.receive(.finalise(.linked(account, institution: institution))) { state in
            state.ui = .linked(institution: state.name)
            state.showActions = true
        }

        XCTAssertEqual(openedURL, url)
    }

    func test_fail() throws {
        store.send(.failure(.bankTransferAccountAlreadyLinked)) { [self] state in
            state.ui = .error(.bankTransferAccountAlreadyLinked, in: environment)
            state.showActions = true
        }
    }

    func test_dismiss() throws {
        store.send(.dismiss)
        XCTAssertTrue(dismiss)
    }
}

final class BankPaymentTests: OpenBankingTestCase {

    typealias Store = TestStore<
        BankState,
        BankAction,
        BankState,
        BankAction,
        Void
    >

    private var store: Store!

    // swiftlint:disable:next force_try
    private lazy var update = try! network[
        URLRequest(.post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update")
    ]
    .unwrap()
    .decode(to: OpenBanking.BankAccount.self)

    // swiftlint:disable:next force_try
    private lazy var payment = try! network[
        URLRequest(.post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment")
    ]
    .unwrap()
    .decode(to: OpenBanking.Payment.self)

    // swiftlint:disable:next force_try
    private lazy var details = try! network[
        URLRequest(.get, "https://api.blockchain.info/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a")
    ]
    .unwrap()
    .decode(to: OpenBanking.Payment.Details.self)

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = .init(
            initialState: initialState,
            reducer: BankReducer(environment: environment)
        )
    }

    var initialState: BankState {
        .init(data: .init(account: createAccount, action: .deposit(amountMinor: "1000", product: "SIMPLEBUY")))
    }

    func test_initial_state() throws {
        let state = initialState
        XCTAssertEqual(state.account, createAccount)
        XCTAssertEqual(state.name, "Your Bank")
        XCTAssertNil(state.ui)
    }

    func test_request() throws {

        store.send(.request) { state in
            state.ui = .communicating(to: state.name)
        }

        scheduler.advance()

        store.receive(.waitingForConsent) { state in
            state.ui = .waiting(for: state.name)
        }

        app.state.set(blockchain.ux.payment.method.open.banking.is.authorised, to: true)
        scheduler.advance()

        store.receive(.finalise(.deposited(details))) { [self] state in
            state.ui = .deposit(success: details, in: environment)
            state.showActions = true
        }
    }
}
