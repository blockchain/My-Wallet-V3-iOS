// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
@testable import PlatformKitMock
import XCTest

class CurrencyFromIdentifierTests: XCTestCase {

    @available(iOS 16, *)
    func testCanExtractCurrencyFromIdentifier() {
        XCTAssertEqual(extractCode(from: "ERC20CryptoAccount.ETH.somePublicKey0123"), "ETH")
        XCTAssertEqual(extractCode(from: "BitcoinCryptoAccount.BTC.xPubAddress0123.bech32"), "BTC")
        XCTAssertEqual(extractCode(from: "BitcoinCashCryptoAccount.BCH.xPubAddress0123.bech32"), "BCH")
        XCTAssertEqual(extractCode(from: "StellarCryptoAccount.XLM.publicKey0123"), "XLM")

        XCTAssertEqual(extractCode(from: "ERC20CryptoAccount.cUSDC.publicKey0123"), "cUSDC")
        XCTAssertEqual(extractCode(from: "ERC20CryptoAccount.stETH.publicKey0123"), "stETH")

        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.stETH.MATIC.publicKey0123"), "stETH.MATIC")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.MATIC.MATIC.publicKey0123"), "MATIC.MATIC")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.BNB.MATIC.publicKey0123"), "BNB.MATIC")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.cUSDC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.cUSDC.lower.publicKey0123"), "cUSDC.lower")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.cUSDC.MATic.publicKey0123"), "cUSDC.MATic")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(extractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")

        XCTAssertNil(extractCode(from: "ERC20CryptoAccount..publicKey"))
    }

    func testFallbackTestCanExtractCurrencyFromIdentifier() {
        XCTAssertEqual(fallBackExtractCode(from: "ERC20CryptoAccount.ETH.somePublicKey0123"), "ETH")
        XCTAssertEqual(fallBackExtractCode(from: "BitcoinCryptoAccount.BTC.xPubAddress0123.bech32"), "BTC")
        XCTAssertEqual(fallBackExtractCode(from: "BitcoinCashCryptoAccount.BCH.xPubAddress0123.bech32"), "BCH")
        XCTAssertEqual(fallBackExtractCode(from: "StellarCryptoAccount.XLM.publicKey0123"), "XLM")

        XCTAssertEqual(fallBackExtractCode(from: "ERC20CryptoAccount.cUSDC.publicKey0123"), "cUSDC")
        XCTAssertEqual(fallBackExtractCode(from: "ERC20CryptoAccount.stETH.publicKey0123"), "stETH")

        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.stETH.MATIC.publicKey0123"), "stETH.MATIC")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.MATIC.MATIC.publicKey0123"), "MATIC.MATIC")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.BNB.MATIC.publicKey0123"), "BNB.MATIC")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.lower.publicKey0123"), "cUSDC.lower")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATic.publicKey0123"), "cUSDC.MATic")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")

        XCTAssertNil(fallBackExtractCode(from: "ERC20CryptoAccount..publicKey"))
    }
}
