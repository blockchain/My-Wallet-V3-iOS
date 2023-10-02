// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import WalletCore
import XCTest
import YenomBitcoinKit

final class GetAccountKeysTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = []
        super.tearDown()
    }

    struct TestCase {
        let coin: BitcoinChainCoin
        let mnemonic: String
        let accountIndex: Int

        let defaultDerivationType: BitcoinChainKit.DerivationType

        let bech32Xpub: String
        let bech32Xpriv: String

        let legacyXpub: String
        let legacyXpriv: String

        let change0WIF: String
        let change1WIF: String

        let receive0WIF: String
        let receive1WIF: String

        let accountPrivateKey: String
    }

    func testGetAccountKeysBitcoinAccount0() {

        let testCase = TestCase(
            coin: .bitcoin,
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus",
            accountIndex: 0,
            defaultDerivationType: .bech32,
            bech32Xpub: "xpub6D4nuUzLPukRYKmb6ZYxo5khwLJXHarYQutgauqv8UkAVV8NHw23UZPDoXdJZDqv5hHiyh55jCER2KuYt2a7Egnoj7TF8u7scsJbJPeCneM", // m/84'/0'/0'
            bech32Xpriv: "xprv9z5SVyTSZYC8Kqh7zY1xRwoyPJU2t88h3gy5nXSJa9DBcgoDkPhnvm4jxFF7XqA1JWx1hGMrCigYodb4Yr6xwTadjq1h2LBsWFYSD5AHihd", // m/84'/0'/0'
            legacyXpub: "xpub6Cqt2PEFm9dYerMNww1t75WhkyZGmVAcVTyt1Pt6LusF1BECwDWP35R3FotsdaMfekBc8uw6kDC8PYuZujkbsfMKrSwP7RhhcseL4SHQ4Di", // m/44'/0'/0'
            legacyXpriv: "xprv9yrXcshMvn5FSNGuquUsjwZyCwinN2Sm8F4HD1UUnaLG8Nu4PgC8VH6ZQXZvhCtDsT6Zotg12jpCNvSx8t9jKtTcRa2si88nSHzsLA9saVH", // m/44'/0'/0'
            change0WIF: "L2VmFLZSuZXaMAg47jXZS6QUviUY9eUGwWG9N7CFLim9jG66BCha", // m/84'/0'/0'/1/0
            change1WIF: "L5cb6CCyDTCkLh4ghUxvYuiMrg4qEWdhR3AwYqBBpfwrFPtnxVX1", // m/84'/0'/0'/1/1
            receive0WIF: "L2crEKLjp8wJRRV3ELcWTZf9EuVEVg6cAMdiVmtkbdW4ePHH3T5a", // m/84'/0'/0'/0/0
            receive1WIF: "L3m7XLXzDjUa6RRguCUyYGnnpXnw18RPfmxsAzBQNA8onNxxUvgs", // m/84'/0'/0'/0/1
            accountPrivateKey: "KxwEhkmNCgDHtY9WQLUjZQtdDCvvWmpJHAaBruSS9hWPaEFyX31K" // m/84'/0'/0'
        )
        runTestCase(testCase)
    }

    func testGetAccountKeysBitcoinAccount1() {

        let testCase = TestCase(
            coin: .bitcoin,
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus",
            accountIndex: 1,
            defaultDerivationType: .bech32,
            bech32Xpub: "xpub6D4nuUzLPukRaXBXWK55p8s7FCZmmXrhHJU7UJFxc9SMyYVFe4TQCYge95zsshNFk2NNxSRKPg1DGAEv5Gbuy5c7XLg1RawjokbTHD5sV3K", // m/84'/0'/1'
            bech32Xpriv: "xprv9z5SVyTSZYC8N374QHY5SzvNhAjHN58qv5YWfurM3ouP6kA76X99ekNAHnWmeaZJs1XweVo6a338DowajTPwuN3x4onwPpqq6EGwGfFSKQq", // m/84'/0'/1'
            legacyXpub: "xpub6Cqt2PEFm9dYiKy5xqW8PXnCtzTiZVmaWGcbDDmrnfJr4EfJeQVyh4qYAG1YrHxn4Goy6dzbGB1T4upyDivg6YMmGMHFqVgr31M2x5vmnsM", // m/44'/0'/1'
            legacyXpriv: "xprv9yrXcshMvn5FVqtcroy82PqULxdEA33j93gzQqNFEKmsBSLA6sBj9GX4Jxi4zQAaKTy2FDCYrByJC8sCFFZTba2Jq7Dj3sHcQXvhzUtdXyr", // m/44'/0'/1'
            change0WIF: "L1UWfq5sPZK2uw9v4xg1roMZCot598b6PCrt9RmmJtsvQ5FRkVz2", // m/84'/0'/1'/1/0
            change1WIF: "Kyva49BqskPMTgPdiedzGU1F4Ymx6jMLXox7C983uJUCTnSeY7Jt", // m/84'/0'/1'/1/1
            receive0WIF: "L575uPa5VCkmhNBAvqWZvzS4HFPLWAjcJJwvofVXUcpSymhFDEBq", // m/84'/0'/1'/0/0
            receive1WIF: "KyT6Nx2vQaqfC9AK7Cy4sY6ep3LmsFVZf1gmcEXtTjkR7fQmUmtH", // m/84'/0'/1'/0/1
            accountPrivateKey: "KyHfumtWcSrB23XA5YVoHGAziLwXx5NZey8SBVETJ5cU3K2xdJy2" // m/84'/0'/0'
        )
        runTestCase(testCase)
    }

    func testGetAccountKeysBitcoinCashAccount0() {

        let testCase = TestCase(
            coin: .bitcoinCash,
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus",
            accountIndex: 0,
            defaultDerivationType: .legacy,
            bech32Xpub: "xpub6D4nuUzLPukRYKmb6ZYxo5khwLJXHarYQutgauqv8UkAVV8NHw23UZPDoXdJZDqv5hHiyh55jCER2KuYt2a7Egnoj7TF8u7scsJbJPeCneM", // m/84'/0'/1'
            bech32Xpriv: "xprv9z5SVyTSZYC8Kqh7zY1xRwoyPJU2t88h3gy5nXSJa9DBcgoDkPhnvm4jxFF7XqA1JWx1hGMrCigYodb4Yr6xwTadjq1h2LBsWFYSD5AHihd", // m/84'/0'/1'
            legacyXpub: "xpub6Cqt2PEFm9dYerMNww1t75WhkyZGmVAcVTyt1Pt6LusF1BECwDWP35R3FotsdaMfekBc8uw6kDC8PYuZujkbsfMKrSwP7RhhcseL4SHQ4Di", // m/44'/0'/1'
            legacyXpriv: "xprv9yrXcshMvn5FSNGuquUsjwZyCwinN2Sm8F4HD1UUnaLG8Nu4PgC8VH6ZQXZvhCtDsT6Zotg12jpCNvSx8t9jKtTcRa2si88nSHzsLA9saVH", // m/44'/0'/1'
            change0WIF: "KwRGDmz6QB8y2QkNBV45nvyJRe9VE7RNnh6n7re56cmcTgHP98Ue", // m/44'/0'/0'/1/0
            change1WIF: "Kz4spLQY4vkXvTgzuV9Rhcj7x4TaWshyzZYaQtAGX9k4SDqkwB5C", // m/44'/0'/0'/1/1
            receive0WIF: "L1CnsYXUFwAM9q4Yi5u8aGqmbkA3ACtapNz66enUtD7ujavPntEG", // m/44'/0'/0'/0/0
            receive1WIF: "L4XCL4XEBmacQJvyLh29LbXWbGvLCKqCRX2sfBJN28hbFTwiVSwH", // m/44'/0'/0'/0/1
            accountPrivateKey: "L25tqq4DUQBZ1cAcLRBbd5VMpphmjANX6KoVkxuNy8K8akVj9HBy" // m/44'/0'/0'
        )
        runTestCase(testCase)
    }

    func testGetAccountKeysBitcoinCashAccount1() {

        let testCase = TestCase(
            coin: .bitcoinCash,
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon cactus",
            accountIndex: 1,
            defaultDerivationType: .legacy,
            bech32Xpub: "xpub6D4nuUzLPukRaXBXWK55p8s7FCZmmXrhHJU7UJFxc9SMyYVFe4TQCYge95zsshNFk2NNxSRKPg1DGAEv5Gbuy5c7XLg1RawjokbTHD5sV3K", // m/84'/0'/1'
            bech32Xpriv: "xprv9z5SVyTSZYC8N374QHY5SzvNhAjHN58qv5YWfurM3ouP6kA76X99ekNAHnWmeaZJs1XweVo6a338DowajTPwuN3x4onwPpqq6EGwGfFSKQq", // m/84'/0'/1'
            legacyXpub: "xpub6Cqt2PEFm9dYiKy5xqW8PXnCtzTiZVmaWGcbDDmrnfJr4EfJeQVyh4qYAG1YrHxn4Goy6dzbGB1T4upyDivg6YMmGMHFqVgr31M2x5vmnsM", // m/44'/0'/1'
            legacyXpriv: "xprv9yrXcshMvn5FVqtcroy82PqULxdEA33j93gzQqNFEKmsBSLA6sBj9GX4Jxi4zQAaKTy2FDCYrByJC8sCFFZTba2Jq7Dj3sHcQXvhzUtdXyr", // m/44'/0'/1'
            change0WIF: "KwjVqrrNctL1rEddHVP9rJzrDZJZEqqgLkXknTVBzEQTem4nMCy8", // m/44'/0'/1'/1/0
            change1WIF: "L1nc6z1kePFx3wajNw2hQsAbiR4asVYuvoP5397doTi3GBEpJUbw", // m/44'/0'/1'/1/1
            receive0WIF: "L35DuWPX96LmyyxinCUn1UisEMshWeGexmyDFGxmKfNjvAYQMU2t", // m/44'/0'/1'/0/0
            receive1WIF: "KxE6jJ26BrLPSEswPJwwADUUWpi9TFZkpXbXch7XgAQra6jpas6p", // m/44'/0'/1'/0/1
            accountPrivateKey: "Kx7XXCWQSDGuvt47SdUKDKvKwC1wyKbvyDiZbRmYrt5svZVyLLRF" // m/44'/0'/1'
        )
        runTestCase(testCase)
    }

    func runTestCase(_ testCase: TestCase) {

        let expectation = expectation(description: "should successfully get account keys")

        let mn = Mnemonic(
            words: testCase.mnemonic
        )

        let mnPublisher: WalletMnemonicProvider = {
            .just(mn)
        }

        let bitcoinChainAccount = BitcoinChainAccount(index: Int32(testCase.accountIndex), coin: testCase.coin)

        let getKeysPublisher = getAccountKeys(
            for: bitcoinChainAccount,
            walletMnemonicProvider: mnPublisher
        )

        // Act
        getKeysPublisher
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("signature should succeed")
                },
                receiveValue: { context in

                    XCTAssertEqual(context.accountIndex, UInt32(testCase.accountIndex))

                    let defaultDerivation = context.defaultDerivation(coin: testCase.coin)

                    XCTAssertEqual(defaultDerivation.type, testCase.defaultDerivationType)

                    XCTAssertEqual(context.derivations.segWit.xpub, testCase.bech32Xpub)
                    XCTAssertEqual(context.derivations.segWit.xpriv, testCase.bech32Xpriv)
                    XCTAssertEqual(context.derivations.legacy.xpub, testCase.legacyXpub)
                    XCTAssertEqual(context.derivations.legacy.xpriv, testCase.legacyXpriv)

                    let change0 = defaultDerivation.changePrivateKey(
                        changeIndex: 0
                    )
                    XCTAssertEqual(change0.data.hex, decodeWIF(string: testCase.change0WIF))
                    let change1 = defaultDerivation.changePrivateKey(
                        changeIndex: 1
                    )
                    XCTAssertEqual(change1.data.hex, decodeWIF(string: testCase.change1WIF))

                    let receive0 = defaultDerivation.receivePrivateKey(
                        receiveIndex: 0
                    )
                    XCTAssertEqual(receive0.data.hex, decodeWIF(string: testCase.receive0WIF))
                    let receive1 = defaultDerivation.receivePrivateKey(
                        receiveIndex: 1
                    )
                    XCTAssertEqual(receive1.data.hex, decodeWIF(string: testCase.receive1WIF))

                    let account = defaultDerivation.accountPrivateKey()
                    XCTAssertEqual(account.data.hex, decodeWIF(string: testCase.accountPrivateKey))

                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Assert
        wait(for: [expectation], timeout: 300)
    }
}

private func decodeWIF(string: String) -> String {
    guard let decodedWif = Base58.decode(string: string) else {
        return ""
    }
    guard let privateKey = PrivateKey(data: decodedWif[1..<33]) else {
        return ""
    }
    return privateKey.data.hex
}
