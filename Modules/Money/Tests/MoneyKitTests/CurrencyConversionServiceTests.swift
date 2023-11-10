// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import MoneyKit
import MoneyKitMock
import TestKit
import XCTest

final class CurrencyConversionServiceTests: XCTestCase {

    private var conversionService: CurrencyConversionServiceAPI!
    private var mockPriceService: PriceServiceMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPriceService = PriceServiceMock()
        conversionService = CurrencyConversionService(priceService: mockPriceService)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        conversionService = nil
        mockPriceService = nil
    }

    func test_converts_fiat_to_crypto() {
        // GIVEN: The price of BTC is $100k and a fiat amount of $2k to convert
        mockPriceService.stubbedResults.priceQuoteAtTime = PriceQuoteAtTime(
            timestamp: Date(),
            moneyValue: MoneyValue.create(minor: 10000000, currency: .fiat(.USD))
        )
        let amountToConvert = MoneyValue.create(minor: 200000, currency: .fiat(.USD))
        // WHEN: The service is asked to convert the USD amount into BTC
        let publisher = conversionService.convert(amountToConvert, to: .crypto(.bitcoin))
        // THEN: The converted amount should be 0.02 BTC
        XCTAssertPublisherValues(publisher, MoneyValue.create(minor: 2000000, currency: .crypto(.bitcoin)))
    }

    func test_converts_crypto_to_fiat() {
        // GIVEN: The price of BTC is $100k and a fiat amount of 2 BTC to convert into USD
        // NOTE: Use the price of BTC in USD because of a hack in PriceService when dealing with fiat -> crypto conversions
        mockPriceService.stubbedResults.priceQuoteAtTime = PriceQuoteAtTime(
            timestamp: Date(),
            moneyValue: MoneyValue.create(minor: 10000000, currency: .fiat(.USD))
        )
        let amountToConvert = MoneyValue.create(minor: 200000000, currency: .crypto(.bitcoin))
        // WHEN: The service is asked to convert the BTC amount into USD
        let publisher = conversionService.convert(amountToConvert, to: .fiat(.USD))
        // THEN: The converted amount should be $200k
        XCTAssertPublisherValues(publisher, MoneyValue.create(minor: 20000000, currency: .fiat(.USD)))
    }

    func test_converts_fiat_to_fiat() {
        // GIVEN: 1 USD costs 0.70 GBP and a fiat amount of $2k to convert
        mockPriceService.stubbedResults.priceQuoteAtTime = PriceQuoteAtTime(
            timestamp: Date(),
            moneyValue: MoneyValue.create(minor: 70, currency: .fiat(.GBP))
        )
        let amountToConvert = MoneyValue.create(minor: 200000, currency: .fiat(.USD))
        // WHEN: The service is asked to convert the USD amount into GBP
        let publisher = conversionService.convert(amountToConvert, to: .fiat(.GBP))
        // THEN: The converted amount should be £1,400.00
        XCTAssertPublisherValues(publisher, MoneyValue.create(minor: 140000, currency: .fiat(.GBP)))
    }

    func test_converts_crypto_to_crypto() {
        // GIVEN: the price of 1 BTC is 10 ETH and a fiat amount of 2 BTC to convert into USD
        mockPriceService.stubbedResults.priceQuoteAtTime = PriceQuoteAtTime(
            timestamp: Date(),
            moneyValue: MoneyValue.create(minor: 1000000000, currency: .crypto(.ethereum))
        )
        let amountToConvert = MoneyValue.create(minor: 200000000, currency: .crypto(.bitcoin))
        // WHEN: The service is asked to convert the BTC amount into ETH
        let publisher = conversionService.convert(amountToConvert, to: .crypto(.ethereum))
        // THEN: The converted amount should be 20 ETH
        XCTAssertPublisherValues(publisher, MoneyValue.create(minor: 2000000000, currency: .crypto(.ethereum)))
    }

    func test_does_not_convert_amount_into_same_currency() {
        // GIVEN: Any amount
        let amountToConvert = MoneyValue.create(minor: 200000, currency: .fiat(.USD))
        // WHEN: The service is asked to convert that amount in the same currency e.g. USD -> USD
        let publisher = conversionService.convert(amountToConvert, to: amountToConvert.currencyType)
        // THEN: The converted amount matches the original amount
        XCTAssertPublisherValues(publisher, amountToConvert)
    }
}
