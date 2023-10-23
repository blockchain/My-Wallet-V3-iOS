// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
import Combine
import DIKit
import PlatformKit
import RxBlocking
import RxSwift
import ToolKit
import WalletPayloadKit
import XCTest

class MockRecorder: Recording {
    func record(_ message: String) {}
    func record() {}

    func error(_ error: Error) {}
    func error(_ errorMessage: String) {}
    func error() {}
    func setUserId(for id: String) {}
    
    func recordIllegalUIOperationIfNeeded() {}
}

class WalletCryptoServiceTests: XCTestCase {

    var service: WalletCryptoServiceAPI!

    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        // Force JS initialization before hand
        let container = modules {
            DependencyContainer.platformKit
            DependencyContainer.walletPayloadKit
            DependencyContainer.blockchainApp
        }
        let service: WalletCryptoServiceAPI = container.resolve()
        self.service = service
    }

    func testDecryption() {
        let key = "keykeykeykeykey"
        let data = "datadatadatadatadata"
        let pbkdf2Iterations: Int = 100

        let expectation = expectation(description: "encrypt and decrypt works")
        expectation.expectedFulfillmentCount = 2

        service
            .encrypt(pair: KeyDataPair(key: key, data: data), pbkdf2Iterations: pbkdf2Iterations)
            .flatMap { encrypted -> AnyPublisher<String, PayloadCryptoError> in
                expectation.fulfill()
                return self.service.decrypt(
                    pair: KeyDataPair(key: key, data: encrypted),
                    pbkdf2Iterations: pbkdf2Iterations
                )
            }
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                XCTFail("Decryption failed with error: \(String(describing: error))")
            }, receiveValue: { decryptedData in
                expectation.fulfill()
                XCTAssertEqual(data, decryptedData)
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
