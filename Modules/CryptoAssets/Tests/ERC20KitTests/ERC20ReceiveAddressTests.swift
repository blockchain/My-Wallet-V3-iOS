// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import ERC20Kit
@testable import EthereumKit
@testable import MoneyDomainKitMock
import MoneyKit
import PlatformKit
import XCTest

final class ERC20ReceiveAddressTests: XCTestCase {

    enum TestCase {
        static let address = "0x8e23ee67d1332ad560396262c48ffbb01f93d052"
        static let contract = "0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359"
        static let sendString = "ethereum:\(address)@33?gasPrice=10&gasLimit=20"
        static let paySendString = "ethereum:pay-\(address)@33?gasPrice=10&gasLimit=20"
        static let transferString = "ethereum:\(contract)@33/transfer?address=\(address)&uint256=1"
    }

    var factory: ERC20ExternalAssetAddressFactory!

    override func setUp() {
        super.setUp()
        let asset = CryptoCurrency.mockERC20(
            symbol: "AAA",
            displaySymbol: "AAA",
            name: "AAA",
            erc20Address: TestCase.contract,
            precision: 18,
            sortIndex: 0
        )
        let currenciesService = MockEnabledCurrenciesService()
        currenciesService.allEnabledEVMNetworks = [.ethereum]
        currenciesService.allEnabledCryptoCurrencies = [
            .ethereum,
            asset
        ]
        factory = ERC20ExternalAssetAddressFactory(
            asset: asset,
            network: .ethereum,
            enabledCurrenciesService: currenciesService
        )
    }

    override func tearDown() {
        factory = nil
        super.tearDown()
    }

    func testQRCodeMetadataTransfer() throws {
        try runTest(address: TestCase.transferString, content: TestCase.address, title: TestCase.address)
    }

    func testQRCodeMetadataSend() throws {
        try runTest(address: TestCase.sendString, content: TestCase.address, title: TestCase.address)
    }

    func testQRCodeMetadataPaySend() throws {
        try runTest(address: TestCase.paySendString, content: TestCase.address, title: TestCase.address)
    }

    private func runTest(address: String, content: String, title: String) throws {
        let receiveAddress = try factory
            .makeExternalAssetAddress(
                address: address,
                label: "Label",
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            .get()
        XCTAssert(receiveAddress is ERC20ReceiveAddress)
        XCTAssert(receiveAddress is QRCodeMetadataProvider)
        guard let qrCodeMetadataProvider = receiveAddress as? QRCodeMetadataProvider else {
            XCTFail("\(type(of: receiveAddress)) not QRCodeMetadataProvider")
            return
        }
        XCTAssertEqual(qrCodeMetadataProvider.qrCodeMetadata.content, TestCase.address)
        XCTAssertEqual(qrCodeMetadataProvider.qrCodeMetadata.title, TestCase.address)
    }
}
