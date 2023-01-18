// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import EthereumKitMock
@testable import MetadataKit
@testable import WalletPayloadKit

import Combine
import ToolKit
import WalletCore
import XCTest

final class EthereumWalletAccountCreationTests: XCTestCase {

    let label = "DeFi Wallet"
    let mnemonic = "business envelope ride merry time drink chat cinnamon hamster left spend gather"

    var metadataServiceMock: MetadataServiceMock!
    var hdWalletProviderCalled: Bool = false
    var hdWalletProvider: WalletCoreHDWalletProvider!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []

        metadataServiceMock = MetadataServiceMock()
        hdWalletProviderCalled = false
        hdWalletProvider = { [mnemonic] () -> AnyPublisher<WalletCore.HDWallet, WalletPayloadKit.WalletError> in
            guard let hdWallet = WalletCore.HDWallet(mnemonic: mnemonic, passphrase: "") else {
                return .failure(WalletError.unknown)
            }
            self.hdWalletProviderCalled = true
            return .just(hdWallet)
        }
    }

    func test_fetches_entry_correctly() {
        // given a normal account
        let account = EthereumEntryPayload.Ethereum.Account(
            address: "0x446335ca6156Fe66e610e7C47e8678cAc5a7a98A",
            archived: false,
            correct: true,
            label: label
        )
        let expectedEntry = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [account],
                defaultAccountIndex: 0,
                erc20: nil,
                hasSeen: false,
                lastTxTimestamp: 0,
                transactionNotes: [:]
            )
        )
        metadataServiceMock.fetchEntryResult = .success(expectedEntry)

        let expectaction = expectation(description: "fetches an entry")

        fetchOrCreateEthereumNatively(
            metadataService: metadataServiceMock,
            hdWalletProvider: hdWalletProvider,
            label: label
        )
        .sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            },
            receiveValue: { [metadataServiceMock] entry in
                XCTAssertTrue(metadataServiceMock!.fetchEntryCalled)
                XCTAssertEqual(entry, expectedEntry)
                expectaction.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectaction], timeout: 10)
    }

    func test_creates_and_saves_entry_when_we_encounter_not_yet_created_error() {
        // given a normal account
        let account = EthereumEntryPayload.Ethereum.Account(
            address: "0x446335ca6156Fe66e610e7C47e8678cAc5a7a98A",
            archived: false,
            correct: true,
            label: label
        )
        let expectedEntry = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [account],
                defaultAccountIndex: 0,
                erc20: nil,
                hasSeen: false,
                lastTxTimestamp: nil,
                transactionNotes: [:]
            )
        )
        // When failure is `notYetCreated`
        metadataServiceMock.fetchEntryResult = .failure(.fetchFailed(.loadMetadataError(.notYetCreated)))

        // And saving the entry succeeds
        metadataServiceMock.saveEntryResult = .success(.noValue)

        let expectaction = expectation(description: "creates and saves entry")

        fetchOrCreateEthereumNatively(
            metadataService: metadataServiceMock,
            hdWalletProvider: hdWalletProvider,
            label: label
        )
        .sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            },
            receiveValue: { [metadataServiceMock] entry in
                XCTAssertTrue(metadataServiceMock!.fetchEntryCalled)
                XCTAssertTrue(metadataServiceMock!.saveEntryCalled)
                XCTAssertTrue(self.hdWalletProviderCalled)
                XCTAssertEqual(entry, expectedEntry)
                expectaction.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectaction], timeout: 10)
    }

    func test_creates_and_saves_entry_when_we_fetch_a_broken_entry() {
        // given a payload that misses ethereum
        let fetchedEntry = EthereumEntryPayload(
            ethereum: nil
        )

        let account = EthereumEntryPayload.Ethereum.Account(
            address: "0x446335ca6156Fe66e610e7C47e8678cAc5a7a98A",
            archived: false,
            correct: true,
            label: label
        )
        let expectedEntry = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [account],
                defaultAccountIndex: 0,
                erc20: nil,
                hasSeen: false,
                lastTxTimestamp: nil,
                transactionNotes: [:]
            )
        )

        // When failure is `notYetCreated`
        metadataServiceMock.fetchEntryResult = .success(fetchedEntry)

        // And saving the entry succeeds
        metadataServiceMock.saveEntryResult = .success(.noValue)

        let expectaction = expectation(description: "creates and saves entry")

        fetchOrCreateEthereumNatively(
            metadataService: metadataServiceMock,
            hdWalletProvider: hdWalletProvider,
            label: label
        )
        .sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            },
            receiveValue: { [metadataServiceMock] entry in
                XCTAssertTrue(metadataServiceMock!.fetchEntryCalled)
                XCTAssertTrue(metadataServiceMock!.saveEntryCalled)
                XCTAssertTrue(self.hdWalletProviderCalled)
                XCTAssertEqual(entry, expectedEntry)
                expectaction.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectaction], timeout: 10)
    }

    func test_creates_and_saves_entry_when_we_fetch_a_broken_entry_with_empty_accounts() {
        // given a payload that misses ethereum
        let fetchedEntry = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [],
                defaultAccountIndex: 0,
                erc20: nil,
                hasSeen: true,
                lastTxTimestamp: 1000,
                transactionNotes: ["tx1_note": "note"]
            )
        )

        let account = EthereumEntryPayload.Ethereum.Account(
            address: "0x446335ca6156Fe66e610e7C47e8678cAc5a7a98A",
            archived: false,
            correct: true,
            label: label
        )
        // the expected payload, in case the fetched has empty accounts
        // it should respect other values and not reset them
        let expectedEntry = EthereumEntryPayload(
            ethereum: EthereumEntryPayload.Ethereum(
                accounts: [account],
                defaultAccountIndex: 0,
                erc20: nil,
                hasSeen: true,
                lastTxTimestamp: 1000,
                transactionNotes: ["tx1_note": "note"]
            )
        )

        // When failure is `notYetCreated`
        metadataServiceMock.fetchEntryResult = .success(fetchedEntry)

        // And saving the entry succeeds
        metadataServiceMock.saveEntryResult = .success(.noValue)

        let expectaction = expectation(description: "creates and saves entry")

        fetchOrCreateEthereumNatively(
            metadataService: metadataServiceMock,
            hdWalletProvider: hdWalletProvider,
            label: label
        )
        .sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            },
            receiveValue: { [metadataServiceMock] entry in
                XCTAssertTrue(metadataServiceMock!.fetchEntryCalled)
                XCTAssertTrue(metadataServiceMock!.saveEntryCalled)
                XCTAssertTrue(self.hdWalletProviderCalled)
                XCTAssertEqual(entry, expectedEntry)
                expectaction.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectaction], timeout: 10)
    }
}

/// Specific mock class for `EthereumEntryPayload`
final class MetadataServiceMock: WalletMetadataEntryServiceAPI {

    var fetchEntryCalled: Bool = false
    var fetchEntryResult = Result<EthereumEntryPayload, WalletAssetFetchError>.failure(.notInitialized)

    func fetchEntry<Entry: MetadataNodeEntry>(type: Entry.Type) -> AnyPublisher<Entry, WalletAssetFetchError> {
        fetchEntryCalled = true
        return fetchEntryResult.map { $0 as! Entry }.publisher
            .eraseToAnyPublisher()
    }

    var saveEntryCalled: Bool = false
    var saveEntryResult: Result<EmptyValue, WalletAssetSaveError> = .failure(.notInitialized)

    func save(node: some MetadataNodeEntry) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
        saveEntryCalled = true
        return saveEntryResult.publisher.eraseToAnyPublisher()
    }
}
