// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import XCTest

class CryptoFormatterTests: XCTestCase {

    private var englishLocale: Locale!
    private var btcFormatter: CryptoFormatter!
    private var ethFormatter: CryptoFormatter!
    private var bchFormatter: CryptoFormatter!
    private var xlmFormatter: CryptoFormatter!

    override func setUp() {
        super.setUp()
        englishLocale = Locale(identifier: "en_US")
        btcFormatter = CryptoFormatter(
            locale: englishLocale,
            cryptoCurrency: .bitcoin,
            minFractionDigits: 1,
            withPrecision: .short
        )
        ethFormatter = CryptoFormatter(
            locale: englishLocale,
            cryptoCurrency: .ethereum,
            minFractionDigits: 1,
            withPrecision: .short
        )
        bchFormatter = CryptoFormatter(
            locale: englishLocale,
            cryptoCurrency: .bitcoinCash,
            minFractionDigits: 1,
            withPrecision: .short
        )
        xlmFormatter = CryptoFormatter(
            locale: englishLocale,
            cryptoCurrency: .stellar,
            minFractionDigits: 1,
            withPrecision: .short
        )
    }

    override func tearDown() {
        englishLocale = nil
        btcFormatter = nil
        ethFormatter = nil
        bchFormatter = nil
        xlmFormatter = nil
        super.tearDown()
    }

    func testFormatWithoutSymbolBtc() {
        XCTAssertEqual(
            "0.00000001",
            btcFormatter.format(minor: 1)
        )
        XCTAssertEqual(
            "0.1",
            btcFormatter.format(major: 0.1)
        )
        XCTAssertEqual(
            "0.0",
            btcFormatter.format(major: 0)
        )
        XCTAssertEqual(
            "1.0",
            btcFormatter.format(major: 1)
        )
        XCTAssertEqual(
            "1,000.0",
            btcFormatter.format(major: 1000)
        )
        XCTAssertEqual(
            "1,000,000.0",
            btcFormatter.format(major: 1000000)
        )
    }

    func testFormatWithSymbolBtc() {
        XCTAssertEqual(
            "0.00000001 BTC",
            btcFormatter.format(minor: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.1 BTC",
            btcFormatter.format(major: 0.1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.0 BTC",
            btcFormatter.format(major: 0, includeSymbol: true)
        )
        XCTAssertEqual(
            "1.0 BTC",
            btcFormatter.format(major: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "1,000.0 BTC",
            btcFormatter.format(major: 1000, includeSymbol: true)
        )
        XCTAssertEqual(
            "1,000,000.0 BTC",
            btcFormatter.format(major: 1000000, includeSymbol: true)
        )
    }

    func testFormatEthShortPrecision() {
        XCTAssertEqual(
            "0.0 ETH",
            ethFormatter.format(minor: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.0 ETH",
            ethFormatter.format(minor: 1000, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.0 ETH",
            ethFormatter.format(minor: 1000000, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.0 ETH",
            ethFormatter.format(minor: 1000000000, includeSymbol: true)
        )
    }

    func testFormatEthLongPrecision() {
        let formatter = CryptoFormatter(
            locale: englishLocale,
            cryptoCurrency: .ethereum,
            minFractionDigits: 1,
            withPrecision: .long
        )
        XCTAssertEqual(
            "0.000000000000000001 ETH",
            formatter.format(minor: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.000000000000001 ETH",
            formatter.format(minor: 1000, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.000000000001 ETH",
            formatter.format(minor: 1000000, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.000000001 ETH",
            formatter.format(minor: 1000000000, includeSymbol: true)
        )
        XCTAssertEqual(
            "2.12345678912345 ETH",
            formatter.format(minor: 2123456789123450000, includeSymbol: true)
        )
    }

    func testFormatWithoutSymbolEth() {
        XCTAssertEqual(
            "0.00000001",
            ethFormatter.format(minor: 10000000000)
        )
        XCTAssertEqual(
            "0.00001",
            ethFormatter.format(minor: 10000000000000)
        )
        XCTAssertEqual(
            "0.1",
            ethFormatter.format(minor: 100000000000000000)
        )
        XCTAssertEqual(
            "1.0",
            ethFormatter.format(minor: 1000000000000000000)
        )
        XCTAssertEqual(
            "10.0",
            ethFormatter.format(major: 10)
        )
        XCTAssertEqual(
            "100.0",
            ethFormatter.format(major: 100)
        )
        XCTAssertEqual(
            "1,000.0",
            ethFormatter.format(major: 1000)
        )
        XCTAssertEqual(
            "1.213333",
            ethFormatter.format(major: 1.213333)
        )
        XCTAssertEqual(
            "1.12345678",
            ethFormatter.format(major: 1.123456789)
        )
    }

    func testFormatWithSymbolEth() {
        XCTAssertEqual(
            "0.00000001 ETH",
            ethFormatter.format(minor: 10000000000, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.00001 ETH",
            ethFormatter.format(minor: 10000000000000, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.1 ETH",
            ethFormatter.format(minor: 100000000000000000, includeSymbol: true)
        )
        XCTAssertEqual(
            "1.213333 ETH",
            ethFormatter.format(major: 1.213333, includeSymbol: true)
        )
        XCTAssertEqual(
            "1.12345678 ETH",
            ethFormatter.format(major: 1.123456789, includeSymbol: true)
        )
        XCTAssertEqual(
            "1.12345678 ETH",
            ethFormatter.format(minor: 1123456789333222111, includeSymbol: true)
        )
    }

    func testFormatWithoutSymbolBch() {
        XCTAssertEqual(
            "0.00000001",
            bchFormatter.format(minor: 1)
        )
        XCTAssertEqual(
            "0.1",
            bchFormatter.format(major: 0.1)
        )
        XCTAssertEqual(
            "0.0",
            bchFormatter.format(major: 0)
        )
        XCTAssertEqual(
            "1.0",
            bchFormatter.format(major: 1)
        )
        XCTAssertEqual(
            "1,000.0",
            bchFormatter.format(major: 1000)
        )
        XCTAssertEqual(
            "1,000,000.0",
            bchFormatter.format(major: 1000000)
        )
    }

    func testFormatWithSymbolBch() {
        XCTAssertEqual(
            "0.00000001 BCH",
            bchFormatter.format(minor: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.1 BCH",
            bchFormatter.format(major: 0.1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.0 BCH",
            bchFormatter.format(major: 0, includeSymbol: true)
        )
        XCTAssertEqual(
            "1.0 BCH",
            bchFormatter.format(major: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "1,000.0 BCH",
            bchFormatter.format(major: 1000, includeSymbol: true)
        )
        XCTAssertEqual(
            "1,000,000.0 BCH",
            bchFormatter.format(major: 1000000, includeSymbol: true)
        )
    }

    func testFormatWithoutSymbolXlm() {
        XCTAssertEqual(
            "0.0000001",
            xlmFormatter.format(minor: 1)
        )
        XCTAssertEqual(
            "0.1",
            xlmFormatter.format(major: 0.1)
        )
        XCTAssertEqual(
            "0.0",
            xlmFormatter.format(major: 0)
        )
        XCTAssertEqual(
            "1.0",
            xlmFormatter.format(major: 1)
        )
        XCTAssertEqual(
            "1,000.0",
            xlmFormatter.format(major: 1000)
        )
        XCTAssertEqual(
            "1,000,000.0",
            xlmFormatter.format(major: 1000000)
        )
    }

    func testFormatWithSymbolXlm() {
        XCTAssertEqual(
            "0.0000001 XLM",
            xlmFormatter.format(minor: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.1 XLM",
            xlmFormatter.format(major: 0.1, includeSymbol: true)
        )
        XCTAssertEqual(
            "0.0 XLM",
            xlmFormatter.format(major: 0, includeSymbol: true)
        )
        XCTAssertEqual(
            "1.0 XLM",
            xlmFormatter.format(major: 1, includeSymbol: true)
        )
        XCTAssertEqual(
            "1,000.0 XLM",
            xlmFormatter.format(major: 1000, includeSymbol: true)
        )
        XCTAssertEqual(
            "1,000,000.0 XLM",
            xlmFormatter.format(major: 1000000, includeSymbol: true)
        )
    }

    func testItalyLocaleFormattingBtc() {
        let italyLocale = Locale(identifier: "it_IT")
        let formatter = CryptoFormatter(
            locale: italyLocale,
            cryptoCurrency: .bitcoin,
            minFractionDigits: 1,
            withPrecision: .long
        )
        XCTAssertEqual(
            "0,00000001",
            formatter.format(minor: 1)
        )
        XCTAssertEqual(
            "0,1",
            formatter.format(major: 0.1)
        )
        XCTAssertEqual(
            "0,0",
            formatter.format(major: 0)
        )
        XCTAssertEqual(
            "1,0",
            formatter.format(major: 1)
        )
        XCTAssertEqual(
            "1.000,0",
            formatter.format(major: 1000)
        )
        XCTAssertEqual(
            "1.000.000,0",
            formatter.format(major: 1000000)
        )
    }
}
