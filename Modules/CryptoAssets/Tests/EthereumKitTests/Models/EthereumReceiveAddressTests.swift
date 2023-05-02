// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import EthereumKit
import MoneyKit
@testable import MoneyKitMock
import XCTest

final class EthereumReceiveAddressTests: XCTestCase {

    enum TestCase {
        static let address = "0x8e23ee67d1332ad560396262c48ffbb01f93d052"
        static let contract = "0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359"
        static let sendString = "ethereum:\(address)@33?value=2.014e18&gasPrice=10&gasLimit=20"
        static let paySendString = "ethereum:pay-\(address)@33?value=2.014e18&gasPrice=10&gasLimit=20"
    }

    var factory: EthereumExternalAssetAddressFactory!

    override func setUp() {
        super.setUp()
        let currenciesService = MockEnabledCurrenciesService()
        currenciesService.allEnabledCryptoCurrencies = [
            .mockERC20(
                symbol: "AAA",
                displaySymbol: "AAA",
                name: "AAA",
                erc20Address: TestCase.contract,
                precision: 18,
                sortIndex: 0
            )
        ]
        factory = EthereumExternalAssetAddressFactory(
            enabledCurrenciesService: currenciesService,
            network: .ethereum
        )
    }

    override func tearDown() {
        factory = nil
        super.tearDown()
    }

    func testQRCodeMetadataSend() {
        let receiveAddress = receiveAddress(TestCase.sendString)!
        XCTAssertEqual(receiveAddress.qrCodeMetadata.content, TestCase.address)
        XCTAssertEqual(receiveAddress.qrCodeMetadata.title, TestCase.address)
    }

    func testQRCodeMetadataPaySend() {
        let receiveAddress = receiveAddress(TestCase.paySendString)!
        XCTAssertEqual(receiveAddress.qrCodeMetadata.content, TestCase.address)
        XCTAssertEqual(receiveAddress.qrCodeMetadata.title, TestCase.address)
    }

    private func receiveAddress(_ address: String) -> EthereumReceiveAddress? {
        try? factory
            .makeExternalAssetAddress(
                address: address,
                label: "Label",
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            .get() as? EthereumReceiveAddress
    }
}
