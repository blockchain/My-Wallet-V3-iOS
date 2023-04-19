// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import EthereumKit
@testable import EthereumKitMock
@testable import PlatformKitMock
import TestKit
import XCTest

final class EthereumKeyPairProviderTests: XCTestCase {

    var subject: EthereumKeyPairProvider!

    override func setUp() {
        super.setUp()

        let mnemonicAccess = MnemonicAccessMock()
        mnemonicAccess.underlyingMnemonic = AnyPublisher.just(MockEthereumWalletTestData.mnemonic)
        let deriver = EthereumKeyPairDeriver()
        subject = EthereumKeyPairProvider(
            mnemonicAccess: mnemonicAccess,
            deriver: deriver
        )
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_load_key_pair() throws {
        let expectedKeyPair = MockEthereumWalletTestData.keyPair

        let result = try subject.keyPair.wait()
        XCTAssertEqual(expectedKeyPair, result)
    }
}
