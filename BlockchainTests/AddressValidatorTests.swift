//
//  AddressValidatorTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 5/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

class AddressValidatorTests: XCTestCase {

    var addressValidator: AddressValidator?

    override func setUp() {
        super.setUp()
        WalletManager.shared.wallet.loadJS()
        let context = WalletManager.shared.wallet.context
        precondition((context != nil), "JS context is required for use of AddressValidator")
        addressValidator = AddressValidator(context: context!)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddressValidatorInitializer() {
        XCTAssertNotNil(addressValidator, "Expected the address validator to have initialized with the JS context.")
    }

    // MARK: - P2PKH Addresses

    func testAddressValidatorWithValidP2PKHAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinAddress(string: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA")
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: address), "Expected address to be valid.")
    }

    func testAddressValidatorWithInValidP2PKHAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinAddress(string: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmO")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    // MARK: - P2SH Addresses (Multi-sig)

    func testAddressValidatorWithValidP2SHAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinAddress(string: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy")
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: address), "Expected address to be valid.")
    }

    // MARK: - Bitcoin Address Validation

    func testAddressValidatorWithShortBitcoinAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinAddress(string: "abc")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    func testAddressValidatorWithLongBitcoinAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinAddress(string: "ThisBitcoinAddressIsWayTooLongToBeValid")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    func testAddressValidatorWithEmptyAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinAddress(string: "")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: address), "Expected address to be invalid.")
    }

    // MARK: - Bitcoin Cash Address Validation

    func testAddressValidatorWithValidLegacyBitcoinAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinCashAddress(string: "1K43HTP8ayuJjfqAHG7azwVDDQaDwLtqtK")
        XCTAssertTrue(addressValidator!.validate(bitcoinCashAddress: address), "Expected address to be invalid.")
    }

    func testAddressValidatorWithValidBitcoinCashAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinCashAddress(string: "qz2js9054gqxj4dww35kkc3jpf0ph4cfh53tld3zek")
        XCTAssertTrue(addressValidator!.validate(bitcoinCashAddress: address), "Expected address to be invalid.")
    }

    func testAddressValidatorWithInvalidBitcoinCashAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = BitcoinCashAddress(string: "DoNotSendYourMoneyToThisAddress")
        XCTAssertFalse(addressValidator!.validate(bitcoinCashAddress: address), "Expected address to be invalid.")
    }

    // MARK: - Ethereum Address Validation

    func testAddressValidatorWithValidEthereumAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = EthereumAddress(string: "0x4A17aE59898427E2c7fE4eB6Cdd88D357F76AA99")
        XCTAssertTrue(addressValidator!.validate(ethereumAddress: address), "Expected address to be invalid.")
    }

    func testAddressValidatorWithInvalidEthereumAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        let address = EthereumAddress(string: "DoNotSendYourEtherToThisAddress")
        XCTAssertFalse(addressValidator!.validate(ethereumAddress: address), "Expected address to be invalid.")
    }
}
