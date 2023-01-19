// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit

import Foundation
import TestKit
import XCTest

class AccountResponseTests: XCTestCase {

    let jsonV3 = Fixtures.loadJSONData(filename: "hdaccount.v3", in: .module)!
    let jsonV4 = Fixtures.loadJSONData(filename: "hdaccount.v4", in: .module)!

    let brokenJsonV3 = Fixtures.loadJSONData(filename: "hdaccount.v3.broken", in: .module)!
    let brokenJsonV4 = Fixtures.loadJSONData(filename: "hdaccount.v4.broken", in: .module)!

    let jsonV4MissingCache = Fixtures.loadJSONData(filename: "hdaccount.v4.missingCache", in: .module)!

    func test_version3_account_can_be_decoded() throws {
        let accountVersion3 = try JSONDecoder().decode(AccountWrapper.Version3.self, from: jsonV3)

        XCTAssertEqual(accountVersion3.label, "DeFi Wallet")
        XCTAssertFalse(accountVersion3.archived)
        XCTAssertEqual(
            accountVersion3.xpriv,
            "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG"
        )
        XCTAssertEqual(
            accountVersion3.xpub,
            "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3"
        )

        XCTAssertEqual(
            accountVersion3.addressLabels,
            [AddressLabelResponse(index: 0, label: "labeled_address")]
        )

        let expectedCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        XCTAssertEqual(
            accountVersion3.cache,
            expectedCache
        )
    }

    func test_broken_version3_account_can_be_decoded() throws {
        let accountVersion3 = try JSONDecoder().decode(AccountWrapper.Version3.self, from: brokenJsonV3)

        XCTAssertEqual(accountVersion3.label, "DeFi Wallet")
        // this should default to `false` for broken accounts
        XCTAssertFalse(accountVersion3.archived)

        XCTAssertEqual(
            accountVersion3.addressLabels,
            []
        )

        let expectedCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        XCTAssertEqual(
            accountVersion3.cache,
            expectedCache
        )
    }

    func test_version4_account_can_be_decoded() throws {
        let accountVersion4 = try JSONDecoder().decode(AccountWrapper.Version4.self, from: jsonV4)

        XCTAssertEqual(accountVersion4.label, "DeFi Wallet")
        XCTAssertFalse(accountVersion4.archived)
        XCTAssertEqual(accountVersion4.defaultDerivation, "bech32")

        XCTAssertFalse(accountVersion4.derivations.isEmpty)
        XCTAssertEqual(accountVersion4.derivations.count, 1)

        let addressLabel = AddressLabelResponse(index: 0, label: "labeled_address")
        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        let expectedDerivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
            addressLabels: [addressLabel],
            cache: addressCache
        )

        XCTAssertEqual(accountVersion4.derivations, [expectedDerivation])
    }

    func test_broken_version4_account_can_be_decoded() throws {
        let accountVersion4 = try JSONDecoder().decode(AccountWrapper.Version4.self, from: brokenJsonV4)

        XCTAssertEqual(accountVersion4.label, "DeFi Wallet")
        // this should default to `false` for broken accounts
        XCTAssertFalse(accountVersion4.archived)
        XCTAssertEqual(accountVersion4.defaultDerivation, "bech32")

        XCTAssertFalse(accountVersion4.derivations.isEmpty)
        XCTAssertEqual(accountVersion4.derivations.count, 1)

        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        let expectedDerivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: nil,
            xpub: nil,
            addressLabels: [],
            cache: addressCache
        )

        XCTAssertEqual(accountVersion4.derivations, [expectedDerivation])
    }

    func test_version3_account_can_be_encoded_to_json() throws {
        let accountVersion3 = AccountWrapper.Version3(
            label: "label",
            archived: false,
            xpriv: "xprv9y",
            xpub: "xpub6",
            addressLabels: [AddressLabelResponse(index: 0, label: "label")],
            cache: AddressCacheResponse(receiveAccount: "receiveAccount", changeAccount: "changeAccount")
        )

        let encoded = try JSONEncoder().encode(accountVersion3)
        let decoded = try JSONDecoder().decode(AccountWrapper.Version3.self, from: encoded)

        XCTAssertEqual(decoded, accountVersion3)
    }

    func test_version4_account_can_be_encoded_to_json() throws {
        let addressLabel = AddressLabelResponse(index: 0, label: "labeled_address")
        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6",
            changeAccount: "xpub6"
        )
        let derivation = DerivationResponse(
            type: .legacy,
            purpose: 44,
            xpriv: "xprv9",
            xpub: "xpub6",
            addressLabels: [addressLabel],
            cache: addressCache
        )

        let accountVersion4 = AccountWrapper.Version4(
            label: "label",
            archived: false,
            defaultDerivation: "bech32",
            derivations: [derivation]
        )

        let encoded = try JSONEncoder().encode(accountVersion4)
        let decoded = try JSONDecoder().decode(AccountWrapper.Version4.self, from: encoded)

        XCTAssertEqual(decoded, accountVersion4)
    }

    func test_it_can_be_decoded_with_missing_derivation_cache() throws {
        let accountVersion4 = try JSONDecoder().decode(AccountWrapper.Version4.self, from: jsonV4MissingCache)

        XCTAssertEqual(accountVersion4.label, "DeFi Wallet")
        // this should default to `false` for broken accounts
        XCTAssertFalse(accountVersion4.archived)
        XCTAssertEqual(accountVersion4.defaultDerivation, "bech32")

        XCTAssertFalse(accountVersion4.derivations.isEmpty)
        XCTAssertEqual(accountVersion4.derivations.count, 1)

        let addressLabel = AddressLabelResponse(index: 0, label: "labeled_address")
        let addressCache = AddressCacheResponse.empty
        let expectedDerivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
            addressLabels: [addressLabel],
            cache: addressCache
        )

        XCTAssertEqual(accountVersion4.derivations, [expectedDerivation])
    }
}
