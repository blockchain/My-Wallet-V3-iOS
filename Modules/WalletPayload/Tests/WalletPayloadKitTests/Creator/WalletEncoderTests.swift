// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletEncoderTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_encoder_transforms_wrapper_correctly() throws {
        let wallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [
                HDWallet(
                    seedHex: "seedHex",
                    passphrase: "",
                    mnemonicVerified: false,
                    defaultAccountIndex: 0,
                    accounts: []
                )
            ],
            addresses: [],
            txNotes: nil,
            addressBook: nil
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "",
            language: "en",
            syncPubKeys: false,
            wallet: wallet
        )

        let expectedEncodedPayload = try JSONEncoder().encode(wrapper.wallet.toWalletResponse)

        let expectation = expectation(description: "provide an encoded payload")

        let encoder = WalletEncoder()
        encoder.transform(wrapper: wrapper)
            .sink { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide a payload")
            } receiveValue: { encodedPayload in
                do {
                    let walletResponse = try JSONDecoder().decode(WalletResponse.self, from: encodedPayload.payloadContext.value)
                    let expectedWalletResponse = try JSONDecoder().decode(WalletResponse.self, from: expectedEncodedPayload)
                    XCTAssertEqual(walletResponse, expectedWalletResponse)
                } catch {
                    XCTFail("could not decode wallet response")
                }
                XCTAssertEqual(encodedPayload.wrapper, wrapper)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_encoder_encodes_wrapper_correctly() throws {
        let wallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [],
            addresses: [],
            txNotes: nil,
            addressBook: nil
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "",
            language: "en",
            syncPubKeys: false,
            wallet: wallet
        )

        let someEncryptedPayload = "1234"

        let innerWrapper = InnerWrapper(pbkdf2IterationCount: 1, version: 4, payload: someEncryptedPayload)

        let encoded = try JSONEncoder().encode(innerWrapper)

        let expectation = expectation(description: "provide an encoded payload")

        let encoder = WalletEncoder()
        let payload = EncodedWalletPayload(payloadContext: .encrypted("1234".data(using: .utf8)!), wrapper: wrapper)
        let applyChecksum = { (_: Data) in "some-checksum" }
        encoder.encode(payload: payload, applyChecksum: applyChecksum)
            .sink { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide a payload")
            } receiveValue: { walletCreationPayload in
                do {
                    let decodedWrapper = try JSONDecoder().decode(InnerWrapper.self, from: walletCreationPayload.innerPayload)
                    let expectedWrapper = try JSONDecoder().decode(InnerWrapper.self, from: encoded)
                    XCTAssertEqual(decodedWrapper, expectedWrapper)
                } catch {
                    XCTFail("could not decode inner wrapper")
                }
                XCTAssertEqual(walletCreationPayload.checksum, "some-checksum")
                XCTAssertEqual(walletCreationPayload.length, encoded.count)
                XCTAssertEqual(walletCreationPayload.guid, wrapper.wallet.guid)
                XCTAssertEqual(walletCreationPayload.sharedKey, wrapper.wallet.sharedKey)
                XCTAssertEqual(walletCreationPayload.language, wrapper.language)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
