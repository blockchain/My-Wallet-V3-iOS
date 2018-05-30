//
//  AddressValidatorTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 5/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class AddressValidatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        WalletManager.shared.wallet.loadJS()
        precondition((WalletManager.shared.wallet.context != nil), "JS context is required for use of AddressValidator")
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - P2PKH Addresses

    func testBitcoinAddressValidatorWithValidP2PKHAddress() {
        let address = BitcoinAddress(string: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA")
        XCTAssertTrue(AddressValidator.shared!.validate(bitcoinAddress: address), "Expected address to be valid.")
    }

    func testBitcoinAddressValidatorWithInValidP2PKHAddress() {
        let address = BitcoinAddress(string: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmO")
        XCTAssertFalse(AddressValidator.shared!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    // MARK: - P2SH Addresses (Multi-sig)

    func testBitcoinAddressValidatorWithValidP2SHAddress() {
        let address = BitcoinAddress(string: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy")
        XCTAssertTrue(AddressValidator.shared!.validate(bitcoinAddress: address), "Expected address to be valid.")
    }

    // MARK: - Invalid Addresses

    func testBitcoinAddressValidatorWithShortAddress() {
        let address = BitcoinAddress(string: "abc")
        XCTAssertFalse(AddressValidator.shared!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    func testBitcoinAddressValidatorWithLongAddress() {
        let address = BitcoinAddress(string: "ThisBitcoinAddressIsWayTooLongToBeValid")
        XCTAssertFalse(AddressValidator.shared!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    func testBitcoinAddressValidatorWithEmptyAddress() {
        let address = BitcoinAddress(string: "")
        XCTAssertFalse(AddressValidator.shared!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    // TODO: add tests for validating BCH and ETH addresses
}
