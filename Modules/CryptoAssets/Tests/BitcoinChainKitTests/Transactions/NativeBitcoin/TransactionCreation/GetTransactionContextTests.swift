// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import Errors
import MetadataHDWalletKit
import WalletCore
import XCTest
import YenomBitcoinKit

final class GetTransactionContextTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = []
        super.tearDown()
    }

    func testGetTransactionContextProvider_importedAddresses() throws {
        let mnProvider: WalletMnemonicProvider = {
            .just(BitcoinChainKit.Mnemonic(words: ""))
        }
        let fetchUnspentOutputs: FetchUnspentOutputsFor = { _ -> AnyPublisher<UnspentOutputs, NetworkError> in
            .just(.init(outputs: []))
        }
        let fetchMultiAddressFor: FetchMultiAddressFor = { _ -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
                .just(.init(addresses: [], latestBlockHeight: 0))
        }
        let publisher = getTransactionContextProvider(
            walletMnemonicProvider: mnProvider,
            fetchUnspentOutputsFor: fetchUnspentOutputs,
            fetchMultiAddressFor: fetchMultiAddressFor
        )

        let account = BitcoinChainAccount(
            index: 0,
            coin: .bitcoin,
            xpub: XPub(address: "1E5az6gZuZjPAXRzBhGNs8mVipe74UccSu", derivationType: .legacy),
            importedPrivateKey: "L1CnsYXUFwAM9q4Yi5u8aGqmbkA3ACtapNz66enUtD7ujavPntEG",
            isImported: true
        )

        let expectation = expectation(description: "should successfully get account keys")

        publisher(account)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("signature should succeed")
                },
                receiveValue: { context in
                    XCTAssert(context.accountKeyContext is ImportedAccountKeyContext)
                    XCTAssertTrue(context.imported)
                    XCTAssertEqual(
                        context.keyPairs,
                        [
                            WalletKeyPair(
                                xpriv: "L1CnsYXUFwAM9q4Yi5u8aGqmbkA3ACtapNz66enUtD7ujavPntEG",
                                privateKeyData: WalletCore.Base58.decodeNoCheck(string: "L1CnsYXUFwAM9q4Yi5u8aGqmbkA3ACtapNz66enUtD7ujavPntEG") ?? Data(),
                                xpub: XPub(address: "1E5az6gZuZjPAXRzBhGNs8mVipe74UccSu", derivationType: .legacy)
                            )
                        ]
                    )
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func testGetTransactionContextProvider_Account() throws {
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus"
        let mnProvider: WalletMnemonicProvider = {
            .just(BitcoinChainKit.Mnemonic(words: mnemonic))
        }
        let fetchUnspentOutputs: FetchUnspentOutputsFor = { _ -> AnyPublisher<UnspentOutputs, NetworkError> in
                .just(
                    UnspentOutputs(
                        outputs: [
                            UnspentOutput(
                                hash: "",
                                hashBigEndian: "",
                                outputIndex: 0,
                                script: "0014a4b111b086430eb388c38a3c6c22a3d1f39e1760",
                                transactionIndex: 0,
                                value: .create(minor: 3338, currency: .bitcoin),
                                xpub: .init(m: "xpub6D4nuUzLPukRYKmb6ZYxo5khwLJXHarYQutgauqv8UkAVV8NHw23UZPDoXdJZDqv5hHiyh55jCER2KuYt2a7Egnoj7TF8u7scsJbJPeCneM", path: "M/0/0")
                            )
                        ]
                    )
                )
        }
        let fetchMultiAddressFor: FetchMultiAddressFor = { _ -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
                .just(
                    BitcoinChainMultiAddressData(
                        addresses: [
                            .init(
                                accountIndex: 0,
                                address: "",
                                changeIndex: 0,
                                finalBalance: 0,
                                nTx: 0,
                                totalReceived: 0,
                                totalSent: 0
                            )
                        ],
                        latestBlockHeight: 0
                    )
                )
        }

        let expectation = expectation(description: "should successfully get account keys")

        let publisher = getTransactionContextProvider(
            walletMnemonicProvider: mnProvider,
            fetchUnspentOutputsFor: fetchUnspentOutputs,
            fetchMultiAddressFor: fetchMultiAddressFor
        )

        let account = BitcoinChainAccount(
            index: 0,
            coin: .bitcoin,
            xpub: nil,
            importedPrivateKey: nil,
            isImported: false
        )

        publisher(account)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("signature should succeed")
                },
                receiveValue: { context in
                    XCTAssert(context.accountKeyContext is AccountKeyContext)
                    XCTAssertFalse(context.imported)
                    XCTAssertEqual(
                        context.keyPairs,
                        [
                            WalletKeyPair(
                                xpriv: "xprv9z5SVyTSZYC8Kqh7zY1xRwoyPJU2t88h3gy5nXSJa9DBcgoDkPhnvm4jxFF7XqA1JWx1hGMrCigYodb4Yr6xwTadjq1h2LBsWFYSD5AHihd",
                                privateKeyData: Data(hex: "a117259b9bee407c176bcd872e04cdc825eb1a189199580a5c28681dc325fd2c"),
                                xpub: XPub(
                                    address: "xpub6D4nuUzLPukRYKmb6ZYxo5khwLJXHarYQutgauqv8UkAVV8NHw23UZPDoXdJZDqv5hHiyh55jCER2KuYt2a7Egnoj7TF8u7scsJbJPeCneM",
                                    derivationType: .bech32
                                )
                            )
                        ]
                    )
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
