// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class HDWalletTests: XCTestCase {

    func test_can_create_an_hd_wallet_from_mnemonic() {
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

        let hdWalletResult = generateHDWallet(mnemonic: mnemonic, accountName: "account name", totalAccounts: 1)

        let expectedSeedHex = "00000000000000000000000000000000"

        let expectedAccounts = [
            Account(
                index: 0,
                label: "account name",
                archived: false,
                defaultDerivation: .segwit,
                derivations: [
                    Derivation(
                        type: .legacy,
                        purpose: DerivationType.legacy.purpose,
                        xpriv: "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb",
                        xpub: "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj",
                        addressLabels: [],
                        cache: AddressCache(
                            receiveAccount: "xpub6ELHKXNimKbxMCytPh7EdC2QXx46T9qLDJWGnTraz1H9kMMFdcduoU69wh9cxP12wDxqAAfbaESWGYt5rREsX1J8iR2TEunvzvddduAPYcY",
                            changeAccount: "xpub6ELHKXNimKbxNg8CV7R31x98ZCPAAT2CrHnZ1ZovqMcvvjnnHmRvLtrpoAs8oBB5YghZf5vzjWURbUBqjXzN3RsEonB3LejZ8oHr3PEJnQj"
                        )
                    ),
                    Derivation(
                        type: .segwit,
                        purpose: DerivationType.segwit.purpose,
                        xpriv: "xprv9ybY78BftS5UGANki6oSifuQEjkpyAC8ZmBvBNTshQnCBcxnefjHS7buPMkkqhcRzmoGZ5bokx7GuyDAiktd5HemohAU4wV1ZPMDRmLpBMm",
                        xpub: "xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V",
                        addressLabels: [],
                        cache: AddressCache(
                            receiveAccount: "xpub6FPnz8nd9KHwrramFPiKretTQ6o7o7JdjjjuVgm9ByvK69i9sfZsTgHSr59PqHcg5E4CmCDbpZ1azNws6XaVNs4Tc9cUwgKQqZmUBoK3xUt",
                            changeAccount: "xpub6FPnz8nd9KHwvCk4KcS6RAqe3odF4cyUV1L2KsnzqyCRUxa7AmWobiftMY1zp1A59UcoVuty6RN4KpnFhCC3yfr1Zr9g3zj5mwpgCdBX6DC"
                        )
                    )
                ]
            )
        ]

        switch hdWalletResult {
        case .success(let hdWallet):
            XCTAssertFalse(hdWallet.mnemonicVerified)
            XCTAssertEqual(hdWallet.seedHex, expectedSeedHex)
            XCTAssertEqual(hdWallet.passphrase, "")
            XCTAssertEqual(hdWallet.defaultAccountIndex, 0)
            XCTAssertFalse(hdWallet.accounts.isEmpty)
            XCTAssertEqual(hdWallet.accounts, expectedAccounts)
            return
        case .failure:
            XCTFail("should provide an hd wallet")
        }
    }

    func test_determines_when_account_needs_replenishment() {
        // on empty accounts
        let hdWalletEmptyAccounts = HDWallet(
            seedHex: "00000000000000000000000000000000",
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: []
        )

        XCTAssertTrue(hdWalletEmptyAccounts.accountsNeedsReplenisment)

        // on empty accounts
        let hdWalletInvalidAccountWithDerivations = HDWallet(
            seedHex: "00000000000000000000000000000000",
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: [
                Account(
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
                        )
                    ]
                ),
                Account(
                    index: 1,
                    label: "DeFi Wallet",
                    archived: false,
                    defaultDerivation: .segwit,
                    derivations: [
                        .init(
                            type: .segwit,
                            purpose: 84,
                            xpriv: "xprv",
                            xpub: "xpub",
                            addressLabels: [],
                            cache: .init(receiveAccount: "", changeAccount: "")
                        )
                    ]
                )
            ]
        )

        XCTAssertTrue(hdWalletInvalidAccountWithDerivations.accountsNeedsReplenisment)
    }
}
