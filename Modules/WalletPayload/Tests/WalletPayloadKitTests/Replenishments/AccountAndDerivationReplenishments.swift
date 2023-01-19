// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

final class AccountAndDerivationReplenishments: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_wallet_with_missing_accounts_recreates_one() throws {
        let seedHex = "00000000000000000000000000000000"
        let hdWalletMissingAccounts = HDWallet(
            seedHex: seedHex,
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: []
        )
        let nativeWallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [hdWalletMissingAccounts],
            addresses: [],
            txNotes: [:],
            addressBook: nil
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "checksum",
            language: "en",
            syncPubKeys: false,
            wallet: nativeWallet
        )

        let expectation = expectation(description: "should create account with correct derivations")

        let expectedAccounts = [
            Account(
                index: 0,
                label: "DeFi Wallet",
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

        runDerivationsReplenishement(
            wrapper: wrapper,
            logger: NoopNativeWalletLogging()
        )
        .sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            },
            receiveValue: { wrapper in
                XCTAssertNotNil(wrapper.wallet.defaultHDWallet)
                XCTAssertFalse(wrapper.wallet.defaultHDWallet!.accounts.isEmpty)

                XCTAssertEqual(wrapper.wallet.defaultHDWallet!.accounts, expectedAccounts)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_wallet_with_broken_derivations_recreates_them() throws {
        let seedHex = "00000000000000000000000000000000"
        let addressLabels: [AddressLabel] = [.init(index: 1, label: "some label"), .init(index: 2, label: "some other label")]
        let hdWalletMissingAccounts = HDWallet(
            seedHex: seedHex,
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
                        .init(type: .legacy, purpose: 44, xpriv: nil, xpub: "", addressLabels: [], cache: .from(model: .empty)),
                        .init(type: .segwit, purpose: 84, xpriv: nil, xpub: "", addressLabels: addressLabels, cache: .from(model: .empty))
                    ]
                )
            ]
        )
        let nativeWallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [hdWalletMissingAccounts],
            addresses: [],
            txNotes: [:],
            addressBook: nil
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "checksum",
            language: "en",
            syncPubKeys: false,
            wallet: nativeWallet
        )

        let expectation = expectation(description: "should create account with correct derivations")

        let expectedAccounts = [
            Account(
                index: 0,
                label: "DeFi Wallet",
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
                        addressLabels: addressLabels,
                        cache: AddressCache(
                            receiveAccount: "xpub6FPnz8nd9KHwrramFPiKretTQ6o7o7JdjjjuVgm9ByvK69i9sfZsTgHSr59PqHcg5E4CmCDbpZ1azNws6XaVNs4Tc9cUwgKQqZmUBoK3xUt",
                            changeAccount: "xpub6FPnz8nd9KHwvCk4KcS6RAqe3odF4cyUV1L2KsnzqyCRUxa7AmWobiftMY1zp1A59UcoVuty6RN4KpnFhCC3yfr1Zr9g3zj5mwpgCdBX6DC"
                        )
                    )
                ]
            )
        ]

        runDerivationsReplenishement(
            wrapper: wrapper,
            logger: NoopNativeWalletLogging()
        )
        .sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            },
            receiveValue: { wrapper in
                XCTAssertNotNil(wrapper.wallet.defaultHDWallet)
                XCTAssertFalse(wrapper.wallet.defaultHDWallet!.accounts.isEmpty)

                XCTAssertEqual(wrapper.wallet.defaultHDWallet!.accounts, expectedAccounts)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
