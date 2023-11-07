// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainNamespace
import Combine
@testable import FeatureDexDomain
@testable import FeatureDexUI
import Foundation
import MoneyKit
import XCTest

final class QuotePayloadFactoryTests: XCTestCase {

    func testOutputMajor() {
        _ = App.preview
        let quote = DexQuoteOutput(
            response: mockTxResponse,
            allowanceSpender: "",
            estimatedConfirmationTime: 52,
            buyAmount: DexQuoteOutput.BuyAmount(amount: ether(major: 2), minimum: ether(major: 1)),
            field: .source,
            isValidated: true,
            fees: [.init(type: .network, value: bitcoin(major: 0.01))],
            sellAmount: bitcoin(major: 1),
            slippage: "0.1234",
            bcdcFeePercentage: "0.008",
            isCrossChain: true
        )
        let result = QuotePayloadFactory.create(quote, service: EnabledCurrenciesService.default)!
        XCTAssertEqual(result.inputCurrency, "BTC")
        XCTAssertEqual(result.inputAmount, "1")

        XCTAssertEqual(result.outputCurrency, "ETH")
        XCTAssertEqual(result.expectedOutputAmount, "2")
        XCTAssertEqual(result.minOutputAmount, "1")

        XCTAssertEqual(result.slippageAllowed, "0.1234")
        XCTAssertEqual(result.networkFeeAmount, "0.01")
        XCTAssertEqual(result.networkFeeCurrency, "BTC")
    }

    func testOutputLong() {
        _ = App.preview
        let quote = DexQuoteOutput(
            response: mockTxResponse,
            allowanceSpender: "",
            estimatedConfirmationTime: 52,
            buyAmount: DexQuoteOutput.BuyAmount(
                amount: ether("2123456789123456789"),
                minimum: ether("1123456789123456789")
            ),
            field: .source,
            isValidated: true,
            fees: [.init(type: .network, value: bitcoin("1234567"))],
            sellAmount: bitcoin("112345678"),
            slippage: "0.123456789",
            bcdcFeePercentage: "0.008",
            isCrossChain: true
        )
        let result = QuotePayloadFactory.create(quote, service: EnabledCurrenciesService.default)!
        XCTAssertEqual(result.inputCurrency, "BTC")
        XCTAssertEqual(result.inputAmount, "1.12345678")

        XCTAssertEqual(result.outputCurrency, "ETH")
        XCTAssertEqual(result.expectedOutputAmount, "2.123456789123456789")
        XCTAssertEqual(result.minOutputAmount, "1.123456789123456789")

        XCTAssertEqual(result.slippageAllowed, "0.123456789")
        XCTAssertEqual(result.networkFeeAmount, "0.01234567")
        XCTAssertEqual(result.networkFeeCurrency, "BTC")
    }

    private func ether(major: Decimal) -> CryptoValue {
        CryptoValue.create(major: major, currency: .ethereum)
    }

    private func bitcoin(major: Decimal) -> CryptoValue {
        CryptoValue.create(major: major, currency: .bitcoin)
    }

    private func ether(_ minor: String) -> CryptoValue {
        CryptoValue.create(minor: minor, currency: .ethereum)!
    }

    private func bitcoin(_ minor: String) -> CryptoValue {
        CryptoValue.create(minor: minor, currency: .bitcoin)!
    }

    private var mockTxResponse: DexQuoteResponse.Transaction {
        .init(data: "", gasLimit: "0", gasPrice: "0", value: "0", to: "")
    }
}
