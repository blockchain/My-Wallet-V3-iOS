// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Coincore
import XCTest

final class CurrencyFromIdentifierTests: XCTestCase {

    @available(iOS 16, *)
    func testCanExtractCurrencyFromIdentifier() {
        XCTAssertEqual(CoincoreHelper.extractCode(from: "ERC20CryptoAccount.ETH.somePublicKey0123"), "ETH")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "BitcoinCryptoAccount.BTC.xPubAddress0123.bech32"), "BTC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "BitcoinCashCryptoAccount.BCH.xPubAddress0123.bech32"), "BCH")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "StellarCryptoAccount.XLM.publicKey0123"), "XLM")

        XCTAssertEqual(CoincoreHelper.extractCode(from: "ERC20CryptoAccount.cUSDC.publicKey0123"), "cUSDC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "ERC20CryptoAccount.stETH.publicKey0123"), "stETH")

        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.stETH.MATIC.publicKey0123"), "stETH.MATIC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.MATIC.MATIC.publicKey0123"), "MATIC.MATIC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.BNB.MATIC.publicKey0123"), "BNB.MATIC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.cUSDC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.cUSDC.lower.publicKey0123"), "cUSDC.lower")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.cUSDC.MATic.publicKey0123"), "cUSDC.MATic")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(CoincoreHelper.extractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")

        XCTAssertNil(CoincoreHelper.extractCode(from: "ERC20CryptoAccount..publicKey"))
    }

    func testFallbackTestCanExtractCurrencyFromIdentifier() {
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "ERC20CryptoAccount.ETH.somePublicKey0123"), "ETH")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "BitcoinCryptoAccount.BTC.xPubAddress0123.bech32"), "BTC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "BitcoinCashCryptoAccount.BCH.xPubAddress0123.bech32"), "BCH")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "StellarCryptoAccount.XLM.publicKey0123"), "XLM")

        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "ERC20CryptoAccount.cUSDC.publicKey0123"), "cUSDC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "ERC20CryptoAccount.stETH.publicKey0123"), "stETH")

        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.stETH.MATIC.publicKey0123"), "stETH.MATIC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.MATIC.MATIC.publicKey0123"), "MATIC.MATIC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.BNB.MATIC.publicKey0123"), "BNB.MATIC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.lower.publicKey0123"), "cUSDC.lower")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATic.publicKey0123"), "cUSDC.MATic")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")
        XCTAssertEqual(CoincoreHelper.fallBackExtractCode(from: "EVMCryptoAccount.cUSDC.MATIC.MATIC.publicKey0123"), "cUSDC.MATIC")

        XCTAssertNil(CoincoreHelper.fallBackExtractCode(from: "ERC20CryptoAccount..publicKey"))
    }
}
