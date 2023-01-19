// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

import Combine
import ObservabilityKit
import TestKit
import ToolKit
import XCTest

class WalletCreatorTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_wallet_creator_can_create_a_wallet() throws {
        let mockServerEntropy = MockServerEntropyRepository()
        mockServerEntropy.serverEntropyResult = .success("00000000000000000000000000000011")
        let rngService = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: { _ in .just(Data(hex: "00000000000000000000000000000001")) },
            operationQueue: DispatchQueue(label: "rng.service.op.queue")
        )
        var uuidProviderCalled = false
        let uuidProvider: UUIDProvider = {
            uuidProviderCalled = true
            return .just(("guid-value", "sharedKey-value"))
        }
        let generatedWallet = generateWallet(
            context: WalletCreationContext(
                mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus",
                guid: "guid-value",
                sharedKey: "sharedKey-value",
                accountName: "DeFi Wallet",
                totalAccounts: 1
            )
        ).success!
        var generateWalletCalled = false
        let generateWalletMock: GenerateWalletProvider = { _ in
            generateWalletCalled = true
            return .success(generatedWallet)
        }
        let generatedWrapper = generateWrapper(wallet: generatedWallet, language: "en", version: .v4)
        var generateWrapperCalled = false
        let generateWrapperMock: GenerateWrapperProvider = { _, language, version in
            generateWrapperCalled = true
            return generateWrapper(wallet: generatedWallet, language: language, version: version)
        }
        let mockCreateRepository = MockCreateWalletRepository()
        let dispatchQueue = DispatchQueue(label: "wallet.creator.temp.op.queue")
        mockCreateRepository.createWallerResult = .just(())

        let mockEncryptor = MockPayloadCrypto()
        mockEncryptor.encryptDataResult = .success("")
        mockEncryptor.decryptWalletBase64StringResult = .success("")

        let mockWalletEncoder = MockWalletEncoder()
        mockWalletEncoder.transformValue = .just(
            EncodedWalletPayload(
                payloadContext: .encoded("".data(using: .utf8)!),
                wrapper: generatedWrapper
            )
        )

        mockWalletEncoder.encodeValue = .just(
            WalletCreationPayload(
                data: "".data(using: .utf8)!,
                wrapper: generatedWrapper,
                applyChecksum: { _ in "" }
            )
        )

        let mockUsedAccountFinder = MockUsedAccountsFinder()
        mockUsedAccountFinder.findUsedAccountResult = .success(0)

        let creator = WalletCreator(
            entropyService: rngService,
            walletEncoder: mockWalletEncoder,
            encryptor: mockEncryptor,
            createWalletRepository: mockCreateRepository,
            usedAccountsFinder: mockUsedAccountFinder,
            operationQueue: dispatchQueue,
            logger: NoopNativeWalletLogging(),
            tracer: LogMessageTracing.noop,
            uuidProvider: uuidProvider,
            generateWallet: generateWalletMock,
            generateWrapper: generateWrapperMock,
            checksumProvider: { _ in "" }
        )

        let expectation = expectation(description: "should create wallet")

        let expectedValue = WalletCreation(guid: "guid-value", sharedKey: "sharedKey-value", password: "1234")
        let email = "some@some.com"
        let password = "1234"
        let accountName = "DeFi Wallet"
        creator.createWallet(email: email, password: password, accountName: accountName, recaptchaToken: nil, siteKey: "", language: "en")
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        return
                    }
                    XCTFail("should not fail: \(error)")
                },
                receiveValue: { value in
                    XCTAssertEqual(value, expectedValue)
                    XCTAssertTrue(mockEncryptor.encryptDataCalled)
                    XCTAssertTrue(mockEncryptor.decryptWalletBase64StringCalled)
                    XCTAssertTrue(mockServerEntropy.getServerEntropyCalled)
                    XCTAssertTrue(uuidProviderCalled)
                    XCTAssertTrue(generateWalletCalled)
                    XCTAssertTrue(generateWrapperCalled)
                    XCTAssertTrue(mockCreateRepository.createWalletCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 4)
    }

    func test_wallet_creator_can_import_a_wallet() throws {
        let mockServerEntropy = MockServerEntropyRepository()
        mockServerEntropy.serverEntropyResult = .success("00000000000000000000000000000011")
        let rngService = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: { _ in .just(Data(hex: "00000000000000000000000000000001")) },
            operationQueue: DispatchQueue(label: "rng.service.op.queue")
        )
        var uuidProviderCalled = false
        let uuidProvider: UUIDProvider = {
            uuidProviderCalled = true
            return .just(("guid-value", "sharedKey-value"))
        }
        let generatedWallet = generateWallet(
            context: WalletCreationContext(
                mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus",
                guid: "guid-value",
                sharedKey: "sharedKey-value",
                accountName: "DeFi Wallet",
                totalAccounts: 2
            )
        ).success!
        var generateWalletCalled = false
        let generateWalletMock: GenerateWalletProvider = { _ in
            generateWalletCalled = true
            return .success(generatedWallet)
        }
        let generatedWrapper = generateWrapper(wallet: generatedWallet, language: "en", version: .v4)
        var generateWrapperCalled = false
        let generateWrapperMock: GenerateWrapperProvider = { _, language, version in
            generateWrapperCalled = true
            return generateWrapper(wallet: generatedWallet, language: language, version: version)
        }
        let mockCreateRepository = MockCreateWalletRepository()
        let dispatchQueue = DispatchQueue(label: "wallet.creator.temp.op.queue")
        mockCreateRepository.createWallerResult = .just(())

        let mockEncryptor = MockPayloadCrypto()
        mockEncryptor.encryptDataResult = .success("")
        mockEncryptor.decryptWalletBase64StringResult = .success("")

        let mockWalletEncoder = MockWalletEncoder()
        mockWalletEncoder.transformValue = .just(
            EncodedWalletPayload(
                payloadContext: .encoded("".data(using: .utf8)!),
                wrapper: generatedWrapper
            )
        )

        mockWalletEncoder.encodeValue = .just(
            WalletCreationPayload(
                data: "".data(using: .utf8)!,
                wrapper: generatedWrapper,
                applyChecksum: { _ in "" }
            )
        )

        let mockUsedAccountFinder = MockUsedAccountsFinder()
        mockUsedAccountFinder.findUsedAccountResult = .success(2)

        let creator = WalletCreator(
            entropyService: rngService,
            walletEncoder: mockWalletEncoder,
            encryptor: mockEncryptor,
            createWalletRepository: mockCreateRepository,
            usedAccountsFinder: mockUsedAccountFinder,
            operationQueue: dispatchQueue,
            logger: NoopNativeWalletLogging(),
            tracer: LogMessageTracing.noop,
            uuidProvider: uuidProvider,
            generateWallet: generateWalletMock,
            generateWrapper: generateWrapperMock,
            checksumProvider: { _ in "" }
        )

        let expectation = expectation(description: "should create wallet")

        let expectedValue = WalletCreation(guid: "guid-value", sharedKey: "sharedKey-value", password: "1234")
        let email = "some@some.com"
        let password = "1234"
        let accountName = "DeFi Wallet"
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus"
        creator.importWallet(mnemonic: mnemonic, email: email, password: password, accountName: accountName, language: "en")
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        return
                    }
                    XCTFail("should not fail: \(error)")
                },
                receiveValue: { value in
                    XCTAssertEqual(value, expectedValue)
                    XCTAssertTrue(mockEncryptor.encryptDataCalled)
                    XCTAssertTrue(mockEncryptor.decryptWalletBase64StringCalled)
                    XCTAssertFalse(mockServerEntropy.getServerEntropyCalled)
                    XCTAssertTrue(uuidProviderCalled)
                    XCTAssertTrue(generateWalletCalled)
                    XCTAssertTrue(generateWrapperCalled)
                    XCTAssertTrue(mockCreateRepository.createWalletCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 4)
    }
}
