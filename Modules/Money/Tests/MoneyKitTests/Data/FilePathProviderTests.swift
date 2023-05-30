// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MoneyKit
import XCTest

final class FilePathProviderTests: XCTestCase {

    var sut: FilePathProviderAPI!

    override func setUp() {
        super.setUp()
        sut = FilePathProvider(fileManager: .default)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testLocalCoinFileIsPresent() {
        guard let localFile = sut.url(fileName: .localCoin) else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-coin.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }

    func testLocalCustodialFileIsPresent() {
        guard let localFile = sut.url(fileName: .localCustodial) else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-custodial.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }

    func testLocalEthereumERC20FileIsPresent() {
        guard let localFile = sut.url(fileName: .localEthereumERC20) else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-ethereum-erc20.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }

    func testLocalOtherERC20FileIsPresent() {
        guard let localFile = sut.url(fileName: .localOtherERC20) else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-other-erc20.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }

    func testLocalNetworkConfigFileIsPresent() {
        guard let localFile = sut.url(fileName: .localNetworkConfig) else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-network-config.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }
}
