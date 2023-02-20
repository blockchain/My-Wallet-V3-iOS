// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

final class DerivationTests: XCTestCase {

    func test_correctly_determines_when_needs_replenishment() {
        let modelMissingXpriv = Derivation(
            type: .segwit,
            purpose: 0,
            xpriv: nil,
            xpub: "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj",
            addressLabels: [],
            cache: AddressCache(receiveAccount: "", changeAccount: "")
        )

        XCTAssertTrue(modelMissingXpriv.needsReplenishment)

        let modelEmptyXpub = Derivation(
            type: .segwit,
            purpose: 0,
            xpriv: "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb",
            xpub: "",
            addressLabels: [],
            cache: AddressCache(receiveAccount: "", changeAccount: "")
        )

        XCTAssertTrue(modelEmptyXpub.needsReplenishment)
    }

    func test_can_create_correct_derivation_for_legacy_type() {
        let masterSeedHex = getHDWallet(
            from: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        ).success!.seed.hexValue

        let key = deriveAccountKey(
            at: 0,
            masterNode: masterSeedHex,
            type: .legacy
        )

        XCTAssertEqual(
            key.xpriv,
            "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb"
        )

        XCTAssertEqual(
            key.xpub,
            "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj"
        )
    }

    func test_can_create_correct_derivation_for_segwit_type() {
        let masterSeedHex = getHDWallet(
            from: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        ).success!.seed.hexValue

        let key = deriveAccountKey(
            at: 0,
            masterNode: masterSeedHex,
            type: .segwit
        )

        XCTAssertEqual(
            key.xpriv,
            "xprv9ybY78BftS5UGANki6oSifuQEjkpyAC8ZmBvBNTshQnCBcxnefjHS7buPMkkqhcRzmoGZ5bokx7GuyDAiktd5HemohAU4wV1ZPMDRmLpBMm"
        )

        XCTAssertEqual(
            key.xpub,
            "xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V"
        )
    }

    func test_can_derive_public_key_data() {
        let mnemonic = "guide air pet hat friend anchor harvest dog depart matter deny awkward sign almost speak short dragon rare private fame depart elevator snake chef"
        let derivationPath = "m/44'/5757'/0'/0/0"
        let masterSeedHex = getHDWallet(from: mnemonic)
            .success!
            .seed
            .hexValue
        let key = derivePublicKeyData(masterNode: masterSeedHex, derivationPath: derivationPath)
        XCTAssertEqual(
            key?.hexValue,
            "022d82baea2d041ac281bebafab11571f45db4f163a9e3f8640b1c804a4ac6f662"
        )
    }

    func test_can_derive_private_key_data() {
        let mnemonic = "guide air pet hat friend anchor harvest dog depart matter deny awkward sign almost speak short dragon rare private fame depart elevator snake chef"
        let derivationPath = "m/44'/5757'/0'/0/0"
        let masterSeedHex = getHDWallet(from: mnemonic)
            .success!
            .seed
            .hexValue
        let key = derivePrivateKeyData(masterNode: masterSeedHex, derivationPath: derivationPath)
        XCTAssertEqual(
            key?.hexValue,
            "0351764dc07ee1ad038ff49c0e020799f0a350dd0769017ea09460e150a64019"
        )
    }
}
