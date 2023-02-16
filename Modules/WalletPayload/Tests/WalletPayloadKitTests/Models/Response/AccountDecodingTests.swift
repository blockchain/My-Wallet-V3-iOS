// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit

import Foundation
import TestKit
import XCTest

class AccountDecodingTests: XCTestCase {

    let jsonV3 = Fixtures.loadJSONData(filename: "hdaccount.v3", in: .module)!
    let jsonV4 = Fixtures.loadJSONData(filename: "hdaccount.v4", in: .module)!
    let jsonV4UnknownDerivation = Fixtures.loadJSONData(filename: "hdaccount.v4.unknown", in: .module)!

    func test_decoding_an_account_from_version3_provides_and_account() throws {
        let accountVersion3 = try JSONDecoder().decode(AccountWrapper.Version3.self, from: jsonV3)

        let addressLabel = AddressLabelResponse(index: 0, label: "labeled_address")
        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        let derivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
            addressLabels: [addressLabel],
            cache: addressCache
        )
        let expectedAccount = AccountResponse(
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .legacy,
            derivations: [derivation]
        )

        let account = decodeAccounts(
            using: accountWrapperDecodingStrategy(version3:),
            value: [accountVersion3]
        )

        switch account {
        case .success(let accounts):
            XCTAssertEqual(accounts.first, expectedAccount)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_decoding_an_account_from_version4_provides_and_account() throws {
        let accountVersion4 = try JSONDecoder().decode(AccountWrapper.Version4.self, from: jsonV4)

        let addressLabel = AddressLabelResponse(index: 0, label: "labeled_address")
        let addressCache = AddressCacheResponse(
            receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
            changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
        )
        let derivation = DerivationResponse(
            type: .legacy,
            purpose: DerivationResponse.Format.legacy.purpose,
            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
            addressLabels: [addressLabel],
            cache: addressCache
        )
        let expectedAccount = AccountResponse(
            label: "DeFi Wallet",
            archived: false,
            defaultDerivation: .segwit,
            derivations: [derivation]
        )

        let account = decodeAccounts(
            using: accountWrapperDecodingStrategy(version4:),
            value: [accountVersion4]
        )

        switch account {
        case .success(let accounts):
            XCTAssertEqual(accounts.first, expectedAccount)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_decoding_an_account_with_an_unknown_derivation_type_throws_error() throws {
        let accountVersion4 = try JSONDecoder().decode(AccountWrapper.Version4.self, from: jsonV4UnknownDerivation)

        XCTAssertThrowsError(
            try decodeAccounts(
                using: accountWrapperDecodingStrategy(version4:),
                value: [accountVersion4]
            )
            .get()
        )
    }
}
