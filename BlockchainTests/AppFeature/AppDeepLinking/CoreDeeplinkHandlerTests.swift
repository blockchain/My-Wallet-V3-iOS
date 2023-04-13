// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import XCTest

@testable import BlockchainApp
@testable import FeatureAppUI

final class CoreDeeplinkHandlerTests: XCTestCase {

    var isBitPayURL = false
    var isPinSetMock = false
    var sut: CoreDeeplinkHandler!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        isPinSetMock = false
        sut = CoreDeeplinkHandler(
            markBitpayUrl: { BitpayService.shared.content = $0 },
            isBitPayURL: { [unowned self] _ in isBitPayURL },
            isPinSet: { [unowned self] in isPinSetMock }
        )
    }

    override func tearDown() {
        isBitPayURL = false
        isPinSetMock = false
        BitpayService.shared.content = nil
        super.tearDown()
    }

    func test_canHandle_when_isPinSet_returns_false() {
        // when
        isPinSetMock = false
        let url = URL(string: "https://")!

        let canHandle = sut.canHandle(url: url)

        XCTAssertFalse(canHandle)
    }

    func test_ignores_if_isPinSet_returns_false() {
        // when
        isPinSetMock = false
        let url = URL(string: "https://")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == .ignore)
    }

    func test_sends_correct_outputs_for_blockchainWallet_scheme() {
        // when
        isPinSetMock = true
        let scheme = AssetConstants.URLSchemes.blockchainWallet
        let url = URL(string: "\(scheme)://")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == .ignore)
    }

    func test_sends_correct_outputs_for_blockchain_scheme() {
        // when
        isPinSetMock = true
        let scheme = AssetConstants.URLSchemes.blockchain
        let url = URL(string: "\(scheme)://")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == .ignore)
    }

    func test_sends_correct_outputs_for_bitpay_urls() {
        // when
        isPinSetMock = true
        isBitPayURL = true
        let url = URL(string: "https://bitpay.com/")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        let outcome = DeeplinkOutcome.handleLink(
            URIContent(url: url, context: .executeDeeplinkRouting)
        )
        XCTAssert(expectedOutcome == outcome)
    }

    func test_sends_correct_outputs_for_bitcoin_url() {
        // when
        isPinSetMock = true
        let url = URL(string: "bitcoin:")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        let outcome = DeeplinkOutcome.handleLink(
            URIContent(url: url, context: .sendCrypto)
        )
        XCTAssert(expectedOutcome == outcome)
    }
}
