// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import PlatformKit
import XCTest

final class BitcoinChainExternalAssetAddressFactoryTests: XCTestCase {
    var sut: BitcoinChainExternalAssetAddressFactory<BitcoinToken>!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    static var validTestCases: [String] = [
        "bc1q2ddhp55sq2l4xnqhpdv0xazg02v9dr7uu8c2p2",
        "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
        "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy",
        "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA",
        "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy",
        "bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq",
        "1K43HTP8ayuJjfqAHG7azwVDDQaDwLtqtK",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq"
    ]

    func testValid() {
        for testcase in Self.validTestCases {
            let result = sut.makeExternalAssetAddress(
                address: testcase,
                label: "",
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            XCTAssertNoThrow(try result.get())
        }
    }

    static var invalidTestCases: [String] = [
        "bc1q2ddhp55sq2l4xnqhpdv9xazg02v9dr7uu8c2p2",
        "MPmoY6RX3Y3HFjGEnFxyuLPCQdjvHwMEny",
        "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmO",
        "abc",
        "ThisBitcoinAddressIsWayTooLongToBeValid",
        "",
        "DoNotSendYourMoneyToThisAddress",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsm"
    ]

    func testInvalid() {
        for testcase in Self.invalidTestCases {
            let result = sut.makeExternalAssetAddress(
                address: testcase,
                label: "",
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            XCTAssertThrowsError(try result.get(), testcase)
        }
    }

    static var bip21TestCases: [String] = [
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq?label=Luke-Jr",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq?amount=20.3&label=Luke-Jr",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq?req-somethingyoudontunderstand=50&req-somethingelseyoudontget=999",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq?somethingyoudontunderstand=50&somethingelseyoudontget=999"
    ]

    func testBIP21() {
        for testCase in Self.bip21TestCases {
            let result = sut.makeExternalAssetAddress(
                address: testCase,
                label: "Test",
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            assertCryptoReceiveAddressIsValid(
                testCase: testCase,
                result: result
            )
        }
    }

    private func assertCryptoReceiveAddressIsValid(
        testCase: String,
        result: Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
    ) {
        var address: CryptoReceiveAddress!
        XCTAssertNoThrow(address = try result.get())
        XCTAssertEqual(address.address, "bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq")
        XCTAssertEqual(address.label, "Test")
        guard let qrCodeMetadataProvider = address as? QRCodeMetadataProvider else {
            XCTFail("Result is not QRCodeMetadataProvider: \(testCase)")
            return
        }
        let qrCodeMetadata = qrCodeMetadataProvider.qrCodeMetadata
        XCTAssertEqual(
            qrCodeMetadata.title,
            "bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq"
        )
        XCTAssertEqual(
            qrCodeMetadata.content,
            "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq"
        )
    }
}
