// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

final class AccountNamingReplenishmentTests: XCTestCase {

    var walletHolder = WalletHolder()
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_can_rename_multiple_account_ignores_and_keeps_the_rest() {
        let seedHex = "00000000000000000000000000000000"
        let hdWallet = HDWallet(
            seedHex: seedHex,
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: [
                account(index: 0, label: "Private Key Wallet"),
                account(index: 1, label: "My Wallet"),
                account(index: 2, label: "Private Key Wallet 2")
            ]
        )
        let nativeWallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [hdWallet],
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

        let expectation = expectation(description: "should update names")

        let walletRepo = WalletRepo(initialState: .empty)
        let walletHolderSpy = WalletHolderSpy(spyOn: walletHolder)
        let walletSync = WalletSyncMock()

        walletSync.syncResult = .success(.noValue)
        walletRepo.set(keyPath: \.credentials.password, value: "some-password")
        walletHolder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
            .subscribe()
            .store(in: &cancellables)

        let sut = AccountRenamingReplenishement(
            walletHolder: walletHolderSpy,
            walletSync: walletSync,
            walletRepo: walletRepo,
            logger: NoopNativeWalletLogging(),
            operationQueue: .main
        )

        let labelsToUpdate: [AccountToRename] = [(index: 0, label: "DeFi Wallet"), (index: 2, label: "DeFi Wallet 2")]

        sut.updateLabels(on: labelsToUpdate)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { _ in
                    XCTAssertTrue(walletSync.syncCalled)

                    let wrapper = self.walletHolder.walletState.value?.wrapper
                    XCTAssertEqual(hdWallet.accounts.count, wrapper?.wallet.defaultHDWallet?.accounts.count ?? 0)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_can_rename_a_single_account_ignores_and_keeps_the_rest() {
        let seedHex = "00000000000000000000000000000000"
        let hdWallet = HDWallet(
            seedHex: seedHex,
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: [
                account(index: 0, label: "Some Wallet"),
                account(index: 1, label: "My Wallet"),
                account(index: 2, label: "Private Key Wallet 2")
            ]
        )
        let nativeWallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [hdWallet],
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

        let expectation = expectation(description: "should update names")

        let walletRepo = WalletRepo(initialState: .empty)
        let walletHolderSpy = WalletHolderSpy(spyOn: walletHolder)
        let walletSync = WalletSyncMock()

        walletSync.syncResult = .success(.noValue)
        walletRepo.set(keyPath: \.credentials.password, value: "some-password")
        walletHolder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
            .subscribe()
            .store(in: &cancellables)

        let sut = AccountRenamingReplenishement(
            walletHolder: walletHolderSpy,
            walletSync: walletSync,
            walletRepo: walletRepo,
            logger: NoopNativeWalletLogging(),
            operationQueue: .main
        )

        let labelsToUpdate: [AccountToRename] = [(index: 2, label: "DeFi Wallet 2")]

        sut.updateLabels(on: labelsToUpdate)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { _ in
                    XCTAssertTrue(walletSync.syncCalled)

                    let wrapper = self.walletHolder.walletState.value?.wrapper
                    XCTAssertEqual(hdWallet.accounts.count, wrapper?.wallet.defaultHDWallet?.accounts.count ?? 0)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }
}

private func account(index: Int, label: String) -> Account {
    Account(
        index: index,
        label: label,
        archived: false,
        defaultDerivation: .segwit,
        derivations: [
            Derivation(
                type: .legacy,
                purpose: DerivationType.legacy.purpose,
                xpriv: "xprv9",
                xpub: "xpub6B",
                addressLabels: [],
                cache: AddressCache(
                    receiveAccount: "xpub6",
                    changeAccount: "xpub6"
                )
            ),
            Derivation(
                type: .segwit,
                purpose: DerivationType.segwit.purpose,
                xpriv: "xprv9",
                xpub: "xpub6C",
                addressLabels: [],
                cache: AddressCache(
                    receiveAccount: "xpub6",
                    changeAccount: "xpub6"
                )
            )
        ]
    )
}
