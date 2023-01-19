// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit

import Foundation
import SwiftExtensions
import TestKit
import XCTest

class WalletResponseTests: XCTestCase {

    let jsonV3 = Fixtures.loadJSONData(filename: "wallet.v3", in: .module)!
    let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    let jsonV3Broken = Fixtures.loadJSONData(filename: "wallet.v3.broken", in: .module)!
    let jsonV4Broken = Fixtures.loadJSONData(filename: "wallet.v4.broken", in: .module)!

    func test_it_should_be_able_to_be_decoded_from_json_version4() throws {
        let wallet = try JSONDecoder().decode(WalletResponse.self, from: jsonV4)

        XCTAssertEqual(wallet.guid, "50dae286-e42e-4d67-8419-d5dcc563746c")
        XCTAssertEqual(wallet.sharedKey, "8a260b2b-5257-4357-ac56-7a7efca323ea")
        XCTAssertEqual(wallet.sharedKey, "8a260b2b-5257-4357-ac56-7a7efca323ea")

        XCTAssertNotNil(wallet.hdWallets)
        XCTAssertFalse(wallet.hdWallets!.isEmpty)
        let hdWallet = wallet.hdWallets!.first!
        XCTAssertEqual(hdWallet.seedHex, "6a4d9524d413fdf69ca1b5664d1d6db0")
        XCTAssertEqual(hdWallet.passphrase, "")
        XCTAssertFalse(hdWallet.mnemonicVerified)
        XCTAssertEqual(hdWallet.defaultAccountIndex, 0)

        XCTAssertFalse(hdWallet.accounts.isEmpty)
        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        let derivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
            addressLabels: [AddressLabelResponse(index: 0, label: "labeled_address")],
            cache: addressCache
        )
        let derivationSegwit = DerivationResponse(
            type: .segwit,
            purpose: DerivationResponse.Format.segwit.purpose,
            xpriv: "xprv9xyd6QiiJ9PHLpoaGZ1J2ZAit27rMoZBsg7pGfZu18Y9KYyeVsbF7fqFoKYD1yVvALxSUeLCD3LGxfk5kPPNQhx1P57ukDfoKRDqjEFTvYT",
            xpub: "xpub6BxyVvFc8WwaZJt3NaYJPh7TS3xLmGH3Eu3R53yWZU58CMJo3QuVfU9jedpAuVA1idn7tJX6TrLVpeifbAySPewVEdH52tSQchLwSznnyCY",
            addressLabels: [AddressLabelResponse(index: 0, label: "labeled_address")],
            cache: AddressCacheResponse(
                receiveAccount: "xpub6EMzXNjqSJ9cwWWPhVjN9EaRnjgaYXwg8WMRcXc9SgP5RpUCFFkDwbqJoAdzBkRCQZB5AA9qh3zk8uEpyzfUDGrXGE23GnCFGoPuYVMTN6C",
                changeAccount: "xpub6EMzXNjqSJ9czvz8pyajFSziPmvSFvhukW8T48jvWs1Zxq9aTDqhfbNzz6DnzkdnvRSxXBBcw4APsbEcsFbFF9zqU8cznBasHhijkrUVnnK"
            )
        )
        let expectedAccount = AccountResponse(
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: DerivationResponse.Format.segwit,
            derivations: [derivation, derivationSegwit]
        )
        XCTAssertFalse(hdWallet.accounts.isEmpty)
        XCTAssertEqual(hdWallet.accounts.first, expectedAccount)
    }

    func test_it_should_be_able_to_be_decoded_from_json_version3() throws {
        let wallet = try JSONDecoder().decode(WalletResponse.self, from: jsonV3)

        XCTAssertEqual(wallet.guid, "50dae286-e42e-4d67-8419-d5dcc563746c")
        XCTAssertEqual(wallet.sharedKey, "8a260b2b-5257-4357-ac56-7a7efca323ea")
        XCTAssertEqual(wallet.sharedKey, "8a260b2b-5257-4357-ac56-7a7efca323ea")

        XCTAssertNotNil(wallet.hdWallets)
        XCTAssertFalse(wallet.hdWallets!.isEmpty)
        let hdWallet = wallet.hdWallets!.first!
        XCTAssertEqual(hdWallet.seedHex, "6a4d9524d413fdf69ca1b5664d1d6db0")
        XCTAssertEqual(hdWallet.passphrase, "")
        XCTAssertFalse(hdWallet.mnemonicVerified)
        XCTAssertEqual(hdWallet.defaultAccountIndex, 0)

        XCTAssertFalse(hdWallet.accounts.isEmpty)
        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        let derivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
            addressLabels: [AddressLabelResponse(index: 0, label: "labeled_address")],
            cache: addressCache
        )
        let expectedAccount = AccountResponse(
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: DerivationResponse.Format.legacy,
            derivations: [derivation]
        )
        XCTAssertFalse(hdWallet.accounts.isEmpty)
        XCTAssertEqual(hdWallet.accounts.first, expectedAccount)
    }

    func test_it_should_be_able_to_be_decoded_from_broken_json_version4() throws {
        let wallet = try JSONDecoder().decode(WalletResponse.self, from: jsonV4Broken)

        XCTAssertEqual(wallet.guid, "50dae286-e42e-4d67-8419-d5dcc563746c")
        XCTAssertEqual(wallet.sharedKey, "8a260b2b-5257-4357-ac56-7a7efca323ea")

        XCTAssertNotNil(wallet.hdWallets)
        XCTAssertFalse(wallet.hdWallets!.isEmpty)
        let hdWallet = wallet.hdWallets!.first!
        XCTAssertEqual(hdWallet.seedHex, "6a4d9524d413fdf69ca1b5664d1d6db0")
        XCTAssertEqual(hdWallet.passphrase, "")
        XCTAssertFalse(hdWallet.mnemonicVerified)
        XCTAssertEqual(hdWallet.defaultAccountIndex, 0)
    }

    func test_it_should_be_able_to_be_decoded_from_broken_json_version3() throws {
        let wallet = try JSONDecoder().decode(WalletResponse.self, from: jsonV3Broken)

        XCTAssertEqual(wallet.guid, "50dae286-e42e-4d67-8419-d5dcc563746c")
        XCTAssertEqual(wallet.sharedKey, "8a260b2b-5257-4357-ac56-7a7efca323ea")

        XCTAssertNotNil(wallet.hdWallets)
        XCTAssertFalse(wallet.hdWallets!.isEmpty)
        let hdWallet = wallet.hdWallets!.first!
        XCTAssertEqual(hdWallet.seedHex, "6a4d9524d413fdf69ca1b5664d1d6db0")
        XCTAssertEqual(hdWallet.passphrase, "")
        XCTAssertFalse(hdWallet.mnemonicVerified)
        XCTAssertEqual(hdWallet.defaultAccountIndex, 0)
    }
}
