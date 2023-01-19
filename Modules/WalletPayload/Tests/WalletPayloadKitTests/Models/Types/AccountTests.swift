// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import TestKit
import ToolKit
import XCTest

final class AccountTests: XCTestCase {

    func test_can_retrieve_default_derivation() {
        let account = Account(
            index: 0,
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .segwit,
            derivations: [
                .init(
                    type: .segwit,
                    purpose: 84,
                    xpriv: "xprv123123",
                    xpub: "xpub123123",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                ),
                .init(
                    type: .legacy,
                    purpose: 44,
                    xpriv: "xprv123123",
                    xpub: "xpub123123",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                )
            ]
        )

        XCTAssertNotNil(account.defaultDerivationAccount)
        XCTAssertEqual(account.defaultDerivationAccount!.type, DerivationType.segwit)

        XCTAssertNotNil(account.derivation(for: .legacy))
        XCTAssertNotNil(account.derivation(for: .segwit))
    }

    func test_correctly_determines_when_needs_replenishment() throws {
        // on empty derivations
        let accountEmptyDerivations = Account(
            index: 0,
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .segwit,
            derivations: []
        )

        XCTAssertTrue(accountEmptyDerivations.needsReplenishment)

        // on missing correct count derivations
        let accountMissingDerivations = Account(
            index: 0,
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .segwit,
            derivations: [
                .init(
                    type: .segwit,
                    purpose: 84,
                    xpriv: "xprivSomething",
                    xpub: "xpubSomething",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                )
            ]
        )

        XCTAssertTrue(accountMissingDerivations.needsReplenishment)

        // on one invalid derivations
        let accountOneInvalidDerivations = Account(
            index: 0,
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .segwit,
            derivations: [
                .init(
                    type: .segwit,
                    purpose: 84,
                    xpriv: nil,
                    xpub: "",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                ),
                .init(
                    type: .legacy,
                    purpose: 44,
                    xpriv: "xprivSomething",
                    xpub: "xpubSomething",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                )
            ]
        )

        XCTAssertTrue(accountOneInvalidDerivations.needsReplenishment)

        // on one invalid derivations
        let accountInvalidDerivations = Account(
            index: 0,
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .segwit,
            derivations: [
                .init(
                    type: .segwit,
                    purpose: 84,
                    xpriv: nil,
                    xpub: "",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                ),
                .init(
                    type: .legacy,
                    purpose: 44,
                    xpriv: nil,
                    xpub: "",
                    addressLabels: [],
                    cache: .init(receiveAccount: "", changeAccount: "")
                )
            ]
        )

        XCTAssertTrue(accountInvalidDerivations.needsReplenishment)
    }
}
