// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
@testable import FeatureOpenBankingUI
import NetworkKit
import TestKit

@MainActor final class InstitutionListTests: OpenBankingTestCase {

    typealias Store = TestStore<
        InstitutionListState,
        InstitutionListAction
    >

    private var store: Store!

    override func setUpWithError() throws {
        try super.setUpWithError()
        do {
            Task { @MainActor in
                store = .init(
                    initialState: .init(),
                    reducer: { InstitutionListReducer(environment: environment) }
                )
            }
        }
    }

    func test_initial_state() throws {
        let state = InstitutionListState()
        XCTAssertNil(state.result)
        XCTAssertNil(state.selection)
        XCTAssertNil(state.route)
    }

    func test_fetch() async throws {
        await store.send(.fetch)
        await scheduler.run()
        await store.receive(.fetched(createAccount)) { [self] state in
            state.result = .success(createAccount)
        }
    }

    func test_show_transfer_details() async throws {
        await store.send(.showTransferDetails)
        XCTAssertTrue(showTransferDetails)
    }

    func test_dismiss() async throws {
        await store.send(.dismiss)
        XCTAssertTrue(dismiss)
    }

    func approve() async {
        await store.send(.fetched(createAccount)) { [self] state in
            state.result = .success(createAccount)
        }
        await store.send(.select(createAccount, institution)) { [self] state in
            state.selection = .init(
                data: .init(
                    account: createAccount,
                    action: .link(
                        institution: institution
                    )
                )
            )
        }
    }

    func test_select_institution() async throws {
        await approve()
    }

    func test_bank_cancel() async throws {
        await approve()

        await scheduler.advance()

        await store.receive(.route(.navigate(to: .bank))) { state in
            state.route = .navigate(to: .bank)
        }

        await store.send(.bank(.cancel)) { state in
            state.route = nil
            state.result = nil
        }
        await store.receive(.fetch)

        await scheduler.advance()

        await store.receive(.fetched(createAccount)) { [self] state in
            state.result = .success(createAccount)
        }
    }
}
