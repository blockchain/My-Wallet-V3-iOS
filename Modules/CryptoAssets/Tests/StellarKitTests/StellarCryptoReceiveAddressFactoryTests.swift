// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
@testable import StellarKit
import XCTest

class StellarCryptoReceiveAddressFactoryTests: XCTestCase {

    var sut: ExternalAssetAddressFactory!
    var address: CryptoReceiveAddress!

    override func setUp() {
        super.setUp()
        sut = StellarCryptoReceiveAddressFactory()
    }

    override func tearDown() {
        sut = nil
        address = nil
        super.tearDown()
    }

    func testInvalidAddress() throws {
        XCTAssertThrowsError(
            address = try sut
                .makeExternalAssetAddress(
                    address: "1234567890",
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )
    }

    func testAddressOnly() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.address,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertNil(address.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testAddressColonMemo() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.addressColonMemo,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testAddressColonMemoWithEqualLabel() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.addressColonMemo,
                    label: StellarTestData.addressColonMemo,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.addressColonMemo)
    }

    func testURLAddress() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.urlString,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertNil(address.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testURLAddressWithMemoWithEqualLabel() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.urlStringWithMemo,
                    label: StellarTestData.urlStringWithMemo,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.urlStringWithMemo)
    }

    func testURLAddressWithMemo() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.urlStringWithMemo,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testURLAddressWithMemoAndType() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.urlStringWithMemoType,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testURLAddressWithMemoAndAmount() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    address: StellarTestData.urlStringWithMemoAndAmount,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }
}
