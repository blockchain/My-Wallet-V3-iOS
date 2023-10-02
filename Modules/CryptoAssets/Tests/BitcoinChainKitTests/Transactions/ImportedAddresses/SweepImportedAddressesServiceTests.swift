// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinChainKitMock

import BlockchainNamespace
import Coincore
import Combine
import Errors
import FeatureTransactionDomain
import MetadataHDWalletKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit
import WalletCore
import XCTest

final class SweepImportedAddressesServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    var receiveBTCAddressProviderMock: BitcoinChainReceiveAddressProvider<BitcoinToken>!
    var receiveBCHAddressProviderMock: BitcoinChainReceiveAddressProvider<BitcoinCashToken>!

    var mockFetchMultiAddressFor: FetchMultiAddressFor!

    override func setUp() {
        super.setUp()
        cancellables = []

        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        let mockMnemonicProvider: WalletMnemonicProvider = { () -> AnyPublisher<BitcoinChainKit.Mnemonic, Error> in
            .just(
                BitcoinChainKit.Mnemonic(
                    words: mnemonic
                )
            )
        }

        mockFetchMultiAddressFor = { xpubs -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            let responses = xpubs.map { xpub in
                BitcoinChainAddressResponse(
                    accountIndex: 0,
                    address: xpub.address,
                    changeIndex: 0,
                    finalBalance: 0,
                    nTx: 0,
                    totalReceived: 0,
                    totalSent: 0
                )
            }
            return .just(
                BitcoinChainMultiAddressData(
                    addresses: responses,
                    latestBlockHeight: 0
                )
            )
        }

        let mockClient = APIClientMock()
        mockClient.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
        let mockUnspentOutputRepo = UnspentOutputRepository(client: mockClient, coin: .bitcoin, app: App.test)

        receiveBTCAddressProviderMock = BitcoinChainReceiveAddressProvider<BitcoinToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo,
            operationQueue: DispatchQueue(label: "receive.address.mock.queue")
        )

        receiveBCHAddressProviderMock = BitcoinChainReceiveAddressProvider<BitcoinCashToken>(
            mnemonicProvider: mockMnemonicProvider,
            fetchMultiAddressFor: mockFetchMultiAddressFor,
            unspentOutputRepository: mockUnspentOutputRepo,
            operationQueue: DispatchQueue(label: "receive.address.mock.queue")
        )
    }

    override func tearDown() {
        cancellables = []
        super.tearDown()
    }

    func test_perform_sweep_works_correctly() throws {

        let mockImportedAddresses: ([String]) -> AnyPublisher<[BitcoinChainCryptoAccount], Error> = { _ in
            .just(
                [
                    MockChainAccount(coinType: .bitcoin, xpub: XPub(address: "1234", derivationType: .legacy), hdAccountIndex: 0, isImported: true, identifier: "a"),
                    MockChainAccount(coinType: .bitcoin, xpub: XPub(address: "12345", derivationType: .legacy), hdAccountIndex: 0, isImported: true, identifier: "b"),
                    MockChainAccount(coinType: .bitcoinCash, xpub: XPub(address: "12346", derivationType: .legacy), hdAccountIndex: 0, isImported: true, identifier: "c")
                ]
            )
        }
        let mockDefaultAccount: (BitcoinChainCoin) -> AnyPublisher<BitcoinChainCryptoAccount, Error> = { _ in
            .just(MockChainAccount(coinType: .bitcoin, xpub: XPub(address: "12", derivationType: .bech32), hdAccountIndex: 0))
        }

        var mockDoPerformSweepResultValue: Result<EmptyValue, Error> = .success(.noValue)
        let mockDoPerfomSweep: DoPerformSweep = { source, _, _ -> AnyPublisher<TxPairResult, Never> in
            .just(
                TxPairResult(
                    accountIdentifier: source.identifier,
                    result: mockDoPerformSweepResultValue
                )
            )
        }

        let appTest = App.test
        var mockRepoLastUpdateDate = Calendar.current.date(bySettingHour: 10, minute: 10, second: 0, of: Date()) ?? Date()
        let mockRepo = SweepImportedAddressesRepository(app: appTest, now: { mockRepoLastUpdateDate })

        let sut = SweepImportedAddressesService(
            sweptBalancesRepository: mockRepo,
            btcAddressProvider: receiveBTCAddressProviderMock,
            bchAddressProvider: receiveBCHAddressProviderMock,
            btcFetchMultiAddrFor: mockFetchMultiAddressFor,
            bchFetchMultiAddrFor: mockFetchMultiAddressFor,
            importedAddresses: mockImportedAddresses,
            defaultAccount: mockDefaultAccount,
            doPerformSweep: mockDoPerfomSweep
        )

        let expecation = expectation(description: "sweep should happen")
        // we have 3 accounts, thus 3 pairs and we expect 1 result per send
        expecation.expectedFulfillmentCount = 3

        sut.prepare(force: false)
            .subscribe()
            .store(in: &cancellables)

        var resultOutput: [TxPairResult] = []

        sut.performSweep()
            .sink { result in
                XCTAssert(result.isNotEmpty)
                resultOutput = result
                expecation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expecation], timeout: 4)

        XCTAssertEqual(resultOutput.count, 3)

        XCTAssertTrue(mockRepo.sweptBalances.isNotEmpty)
        XCTAssertEqual(mockRepo.sweptBalances, ["a", "b", "c"])
        let lastUpdateDate = try? appTest.state.get(blockchain.ux.sweep.imported.addresses.swept.last.update, as: Date.self)
        XCTAssertNotNil(lastUpdateDate)
        XCTAssertEqual(lastUpdateDate, mockRepoLastUpdateDate)
    }

    func test_do_perform_sweep_works_correctly() throws {
        let source = MockChainAccount(coinType: .bitcoin, xpub: XPub(address: "1234", derivationType: .bech32), hdAccountIndex: 0)
        let target = BitcoinChainReceiveAddress<BitcoinToken>(address: "123", label: "") { _ in
            .empty()
        }
        let mockTxEngine = MockOnChainTxEngine()
        let txFactory: (BitcoinChainCryptoAccount) -> OnChainTransactionEngine = { _ in
            mockTxEngine
        }
        let expectation = expectation(description: "expect addresses to be correct")

        doPerformSweep(on: source, target: target, txFactory: txFactory)
            .sink { result in
                XCTAssertTrue(mockTxEngine.startCalled)
                XCTAssertTrue(mockTxEngine.initializeTransactionCalled.0)
                XCTAssertTrue(mockTxEngine.updatedAmountCalled.0)
                XCTAssertTrue(mockTxEngine.doValidateAllCalled.0)
                XCTAssertTrue(mockTxEngine.executeCalled)
                XCTAssertTrue(mockTxEngine.doPostExecuteCalled)
                XCTAssertEqual(result, TxPairResult(accountIdentifier: source.identifier, result: .success(.noValue)))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_get_latest_receive_index_for() throws {
        let xpub = XPub(address: "123", derivationType: .legacy)

        let latestReceiveIndex = getLatestReceiveIndexFor(xpub: xpub) { _ -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            .just(
                BitcoinChainMultiAddressData(
                    addresses: [
                        BitcoinChainAddressResponse(
                            accountIndex: 3,
                            address: xpub.address,
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

        latestReceiveIndex.sink { value in
            XCTAssertEqual(value, 3)
        }
        .store(in: &cancellables)

        getLatestReceiveIndexFor(xpub: xpub) { _ -> AnyPublisher<BitcoinChainMultiAddressData, NetworkError> in
            .just(
                BitcoinChainMultiAddressData(
                    addresses: [],
                    latestBlockHeight: 0
                )
            )
        }
        .sink { value in
            XCTAssertEqual(value, 0)
        }
        .store(in: &cancellables)
    }

    func test_provides_imported_addresses_correctly() throws {
        let mockCoincore = MockCoincore()
        let mockBTCCandidateProvider = MockTransactionCandidateProvider()
        let mockBCHCandidateProvider = MockTransactionCandidateProvider()
        let mockDefaultAccount = CurrentValueSubject<MockChainAccount, Error>(MockChainAccount(coinType: .bitcoin, xpub: .init(address: "", derivationType: .legacy), hdAccountIndex: 0))
        let provider = importedAddressesProvider(
            coincore: mockCoincore,
            btcCandidateProvider: mockBTCCandidateProvider,
            bchCandidateProvider: mockBCHCandidateProvider,
            dispatchQueue: DispatchQueue(label: "temp"),
            defaultAccountProvider: { _ -> AnyPublisher<BitcoinChainCryptoAccount, Error> in
                mockDefaultAccount.map { $0 as BitcoinChainCryptoAccount }.eraseToAnyPublisher()
            }
        )

        let defaultAccount = MockChainAccount(
            coinType: .bitcoin,
            xpub: .init(address: "1234", derivationType: .bech32),
            hdAccountIndex: 0,
            isImported: false,
            isDefault: true
        )

        mockCoincore.mockAccounts = [
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true,
                isDefault: false,
                mockBalance: .one(currency: .bitcoin)
            ),
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true,
                isDefault: false,
                mockBalance: .one(currency: .bitcoin)
            ),
            defaultAccount
        ]

        mockBTCCandidateProvider.maxSpandable.value = .one(currency: .bitcoin)
        mockBCHCandidateProvider.maxSpandable.value = .create(minor: BitcoinChainCoin.bitcoin.dust, currency: .bitcoin)

        mockDefaultAccount.value = defaultAccount

        let expectation = expectation(description: "expect addresses to be correct")

        provider([])
            .sink(
                receiveValue: { value in
                    XCTAssertFalse(value.isEmpty)
                    XCTAssertEqual(value.count, 2)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_provides_imported_addresses_skips_any_swept_identifier() throws {
        let mockCoincore = MockCoincore()
        let mockBTCCandidateProvider = MockTransactionCandidateProvider()
        let mockBCHCandidateProvider = MockTransactionCandidateProvider()
        let mockDefaultAccount = CurrentValueSubject<MockChainAccount, Error>(MockChainAccount(coinType: .bitcoin, xpub: .init(address: "", derivationType: .legacy), hdAccountIndex: 0))
        let provider = importedAddressesProvider(
            coincore: mockCoincore,
            btcCandidateProvider: mockBTCCandidateProvider,
            bchCandidateProvider: mockBCHCandidateProvider,
            dispatchQueue: DispatchQueue(label: "temp"),
            defaultAccountProvider: { _ -> AnyPublisher<BitcoinChainCryptoAccount, Error> in
                mockDefaultAccount.map { $0 as BitcoinChainCryptoAccount }.eraseToAnyPublisher()
            }
        )

        let defaultAccount = MockChainAccount(
            coinType: .bitcoin,
            xpub: .init(address: "1234", derivationType: .bech32),
            hdAccountIndex: 0,
            isImported: false,
            isDefault: true
        )

        mockCoincore.mockAccounts = [
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true,
                isDefault: false,
                mockBalance: .one(currency: .bitcoin),
                identifier: "BTC.123.legacy"
            ),
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "1234", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true,
                isDefault: false,
                mockBalance: .one(currency: .bitcoin),
                identifier: "BTC.1234.legacy"
            ),
            defaultAccount
        ]

        mockBTCCandidateProvider.maxSpandable.value = .one(currency: .bitcoin)
        mockBCHCandidateProvider.maxSpandable.value = .create(minor: BitcoinChainCoin.bitcoin.dust, currency: .bitcoin)

        mockDefaultAccount.value = defaultAccount

        let expectation = expectation(description: "expect addresses to be correct")

        let previouslySweptBalances = ["BTC.123.legacy"]

        provider(previouslySweptBalances)
            .sink(
                receiveValue: { value in
                    XCTAssertFalse(value.isEmpty)
                    XCTAssertEqual(value.count, 1)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_provides_imported_addresses_correctly_zero_max() throws {
        let mockCoincore = MockCoincore()
        let mockBTCCandidateProvider = MockTransactionCandidateProvider()
        let mockBCHCandidateProvider = MockTransactionCandidateProvider()
        let mockDefaultAccount = CurrentValueSubject<MockChainAccount, Error>(MockChainAccount(coinType: .bitcoin, xpub: .init(address: "", derivationType: .legacy), hdAccountIndex: 0))
        let provider = importedAddressesProvider(
            coincore: mockCoincore,
            btcCandidateProvider: mockBTCCandidateProvider,
            bchCandidateProvider: mockBCHCandidateProvider,
            dispatchQueue: DispatchQueue(label: "temp"),
            defaultAccountProvider: { _ -> AnyPublisher<BitcoinChainCryptoAccount, Error> in
                mockDefaultAccount.map { $0 as BitcoinChainCryptoAccount }.eraseToAnyPublisher()
            }
        )

        let defaultAccount = MockChainAccount(
            coinType: .bitcoin,
            xpub: .init(address: "1234", derivationType: .bech32),
            hdAccountIndex: 0,
            isImported: false,
            isDefault: true
        )

        mockCoincore.mockAccounts = [
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true,
                isDefault: false,
                mockBalance: .one(currency: .bitcoin)
            ),
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true,
                isDefault: false,
                mockBalance: .one(currency: .bitcoin)
            ),
            defaultAccount
        ]

        mockBTCCandidateProvider.maxSpandable.value = .zero(currency: .bitcoin)
        mockBCHCandidateProvider.maxSpandable.value = .create(minor: BitcoinChainCoin.bitcoin.dust, currency: .bitcoin)

        mockDefaultAccount.value = defaultAccount

        let expectation = expectation(description: "expect addresses to be correct")

        provider([])
            .sink(
                receiveValue: { value in
                    XCTAssertTrue(value.isEmpty)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_balance_is_spendable() throws {
        var result = balanceIsSpendable(nil, coin: .bitcoin)
        XCTAssertFalse(result)

        result = balanceIsSpendable(.zero(currency: .bitcoin), coin: .bitcoin)
        XCTAssertFalse(result)

        result = balanceIsSpendable(.one(currency: .bitcoin), coin: .bitcoin)
        XCTAssertTrue(result)

        result = balanceIsSpendable(.create(minorDouble: 546, currency: .bitcoin), coin: .bitcoin)
        XCTAssertFalse(result)
    }

    func test_can_correctly_output_btc_pairs_from_context_receiveAddress() throws {
        let imported = [
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            ),
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "1233", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            )
        ]
        let context = PairsContext(
            btcReceiveIndex: 0,
            bchReceiveIndex: 0,
            imported: imported,
            btcDefaultAccount: MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "", derivationType: .bech32),
                hdAccountIndex: 0
            ),
            bchDefaultAccount: MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "", derivationType: .legacy),
                hdAccountIndex: 0
            )
        )

        let pairsPublisher = btcTxPairs(context: context, btcAddressProvider: receiveBTCAddressProviderMock)

        let expecation = expectation(description: "expect addresses to be correct")

        pairsPublisher
            .sink { pairs in
                XCTAssertFalse(pairs.isEmpty)
                XCTAssertEqual(pairs.count, 2)
                XCTAssertEqual(pairs[0].target.address, "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu")
                XCTAssertEqual(pairs[1].target.address, "bc1qnjg0jd8228aq7egyzacy8cys3knf9xvrerkf9g")
                expecation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expecation], timeout: 2)
    }

    func test_can_correctly_output_btc_pairs_from_context_receiveIndex() throws {
        let imported = [
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            ),
            MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "1233", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            )
        ]
        let context = PairsContext(
            btcReceiveIndex: 5, // given a receiveIndex
            bchReceiveIndex: 0,
            imported: imported,
            btcDefaultAccount: MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "", derivationType: .bech32),
                hdAccountIndex: 0
            ),
            bchDefaultAccount: MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "", derivationType: .legacy),
                hdAccountIndex: 0
            )
        )

        let pairsPublisher = btcTxPairs(context: context, btcAddressProvider: receiveBTCAddressProviderMock)
        let expecation = expectation(description: "expect addresses to be correct")

        pairsPublisher
            .sink { pairs in
                XCTAssertFalse(pairs.isEmpty)
                XCTAssertEqual(pairs.count, 2)
                XCTAssertEqual(pairs[0].target.address, "bc1qnpzzqjzet8gd5gl8l6gzhuc4s9xv0djt0rlu7a")
                XCTAssertEqual(pairs[1].target.address, "bc1qtet8q6cd5vqm0zjfcfm8mfsydju0a29ggqrmu9")
                expecation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expecation], timeout: 2)
    }

    func test_can_correctly_output_bch_pairs_from_context() throws {
        // given two imported accounts
        let imported = [
            MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            ),
            MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "1233", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            )
        ]
        // and with a bchReceiveIndex
        let context = PairsContext(
            btcReceiveIndex: 0,
            bchReceiveIndex: 0,
            imported: imported,
            btcDefaultAccount: MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "", derivationType: .bech32),
                hdAccountIndex: 0
            ),
            bchDefaultAccount: MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "", derivationType: .legacy),
                hdAccountIndex: 0
            )
        )

        // when
        let pairsPublisher = bchTxPairs(
            context: context,
            bchAddressProvider: receiveBCHAddressProviderMock
        )

        let expecation = expectation(description: "expect addresses to be correct")

        // then
        pairsPublisher
            .sink { pairs in
                XCTAssertFalse(pairs.isEmpty)
                XCTAssertEqual(pairs.count, 2)
                XCTAssertEqual(pairs[0].target.address, "bitcoincash:qrvcdmgpk73zyfd8pmdl9wnuld36zh9n4gms8s0u59")
                XCTAssertEqual(pairs[1].target.address, "bitcoincash:qp4wzvqu73x22ft4r5tk8tz0aufdz9fescwtpcmhc7")
                expecation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expecation], timeout: 2)
    }

    func test_can_correctly_output_bch_pairs_from_context_receiveIndex() throws {
        // given two imported accounts
        let imported = [
            MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "123", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            ),
            MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "1233", derivationType: .legacy),
                hdAccountIndex: 0,
                isImported: true
            )
        ]
        // and with a bchReceiveIndex
        let context = PairsContext(
            btcReceiveIndex: 0,
            bchReceiveIndex: 4,
            imported: imported,
            btcDefaultAccount: MockChainAccount(
                coinType: .bitcoin,
                xpub: .init(address: "", derivationType: .bech32),
                hdAccountIndex: 0
            ),
            bchDefaultAccount: MockChainAccount(
                coinType: .bitcoinCash,
                xpub: .init(address: "", derivationType: .legacy),
                hdAccountIndex: 0
            )
        )

        // when
        let pairsPublisher = bchTxPairs(
            context: context,
            bchAddressProvider: receiveBCHAddressProviderMock
        )

        // then
        let expecation = expectation(description: "expect addresses to be correct")

        // then
        pairsPublisher
            .sink { pairs in
                XCTAssertFalse(pairs.isEmpty)
                XCTAssertEqual(pairs.count, 2)
                XCTAssertEqual(pairs[0].target.address, "bitcoincash:qzkvwh3qg6jhlcx4cjrhce6jzss8a5jdhu5x8259tw")
                XCTAssertEqual(pairs[1].target.address, "bitcoincash:qp0q87wfzrgtfzu7wg9l4m4elvev54hm4533dnxd5f")
                expecation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expecation], timeout: 2)
    }
}

// MARK: - Mocks

class MockChainAccount: BitcoinChainCryptoAccount {
    var coinType: BitcoinChainKit.BitcoinChainCoin
    var hdAccountIndex: Int
    var xPub: XPub
    var isImported: Bool
    var importedPrivateKey: String?
    var identifier: String

    var mockBalance = CurrentValueSubject<MoneyValue, Error>(.zero(currency: .bitcoin))
    var mockReceiveAddress = CurrentValueSubject<Coincore.ReceiveAddress, Error>(BitcoinChainReceiveAddress<BitcoinToken>(address: "", label: "", onTxCompleted: { _ in .empty() }))

    init(
        coinType: BitcoinChainKit.BitcoinChainCoin,
        xpub: XPub,
        hdAccountIndex: Int,
        isImported: Bool = false,
        isDefault: Bool = false,
        mockBalance: MoneyValue = .zero(currency: .bitcoin),
        identifier: String = ""
    ) {
        self.coinType = coinType
        self.xPub = xpub
        self.hdAccountIndex = hdAccountIndex
        self.isImported = isImported
        self.isDefault = isDefault
        self.mockBalance.value = mockBalance
        self.identifier = identifier
    }

    func createTransactionEngine() -> Any {
        MockOnChainTxFactory()
    }

    var asset: MoneyKit.CryptoCurrency = MoneyKit.CryptoCurrency.bitcoin
    var isDefault: Bool = false

    func can(perform action: Coincore.AssetAction) -> AnyPublisher<Bool, Error> {
        .just(false)
    }

    var receiveAddress: AnyPublisher<Coincore.ReceiveAddress, Error> {
        mockReceiveAddress.eraseToAnyPublisher()
    }

    var balance: AnyPublisher<MoneyKit.MoneyValue, Error> {
        mockBalance.eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyKit.MoneyValue, Error> {
        .empty()
    }

    var actionableBalance: AnyPublisher<MoneyKit.MoneyValue, Error> {
        .empty()
    }

    func invalidateAccountBalance() {}

    var label: String = ""
    var assetName: String = ""

    func balancePair(fiatCurrency: MoneyKit.FiatCurrency, at time: MoneyKit.PriceTime) -> AnyPublisher<MoneyKit.MoneyValuePair, Error> {
        .empty()
    }

    func mainBalanceToDisplayPair(fiatCurrency: MoneyKit.FiatCurrency, at time: MoneyKit.PriceTime) -> AnyPublisher<MoneyKit.MoneyValuePair, Error> {
        .empty()
    }
}

class MockCoincore: CoincoreAPI {
    func allAccounts(filter: Coincore.AssetFilter) -> AnyPublisher<Coincore.AccountGroup, Coincore.CoincoreError> {
        .empty()
    }

    func accounts(filter: Coincore.AssetFilter, where isIncluded: @escaping (Coincore.BlockchainAccount) -> Bool) -> AnyPublisher<[Coincore.BlockchainAccount], Error> {
        .just(mockAccounts.filter(isIncluded))
    }

    func accounts(where isIncluded: @escaping (Coincore.BlockchainAccount) -> Bool) -> AnyPublisher<[Coincore.BlockchainAccount], Error> {
        .just(mockAccounts.filter(isIncluded))
    }

    var allAssets: [Coincore.Asset] = []
    var fiatAsset: Coincore.Asset = MockFiatAsset()
    var cryptoAssets: [Coincore.CryptoAsset] = []

    var mockAccounts: [Coincore.BlockchainAccount] = []

    func initialize() -> AnyPublisher<Void, Never> {
        .empty()
    }

    func registerNonCustodialAssetLoader(handler: @escaping () -> AnyPublisher<[MoneyKit.CryptoCurrency], Never>) {}

    func getTransactionTargets(sourceAccount: Coincore.BlockchainAccount, action: Coincore.AssetAction) -> AnyPublisher<[Coincore.SingleAccount], Coincore.CoincoreError> {
        .empty()
    }

    subscript(cryptoCurrency: MoneyKit.CryptoCurrency) -> Coincore.CryptoAsset? {
        nil
    }

    func account(_ identifier: String) -> AnyPublisher<Coincore.BlockchainAccount?, Never> {
        .just(nil)
    }
}

class MockFiatAsset: Asset {
    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        .empty()
    }

    func transactionTargets(
        account: SingleAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], Never> {
        .empty()
    }

    func parse(address: String, memo: String?) -> AnyPublisher<Coincore.ReceiveAddress?, Never> {
        .empty()
    }
}

class MockTransactionCandidateProvider: TransactionCandidateProviderAPI {

    var candidate = CurrentValueSubject<NativeBitcoinTransactionCandidate?, Error>(nil)
    var maxSpandable = CurrentValueSubject<CryptoValue, Error>(.zero(currency: .bitcoin))

    func getCandidate(
        sourceAccount: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        amount: CryptoValue,
        feeLevel: BitcoinChainPendingTransaction.FeeLevel
    ) -> AnyPublisher<NativeBitcoinTransactionCandidate, Error> {
        candidate.compactMap { $0 }.eraseToAnyPublisher()
    }

    func getMaxSpendable(
        sourceAccount: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        amount: CryptoValue,
        feeLevel: BitcoinChainPendingTransaction.FeeLevel
    ) -> AnyPublisher<CryptoValue, Error> {
        maxSpandable.eraseToAnyPublisher()
    }
}

class MockOnChainTxFactory: OnChainTransactionEngineFactory {
    func build() -> OnChainTransactionEngine {
        MockOnChainTxEngine()
    }
}

class MockFiatCurrencyService: MoneyKit.FiatCurrencyServiceAPI {
    var displayCurrencyPublisher: AnyPublisher<MoneyKit.FiatCurrency, Never> = .empty()

    var tradingCurrencyPublisher: AnyPublisher<MoneyKit.FiatCurrency, Never> = .empty()
}

class MockCurrencyConversionService: PlatformKit.CurrencyConversionServiceAPI {
    func conversionRate(from sourceCurrency: MoneyKit.CurrencyType, to targetCurrency: MoneyKit.CurrencyType) -> AnyPublisher<MoneyKit.MoneyValue, MoneyKit.PriceServiceError> {
        .empty()
    }

    func convert(_ amount: MoneyKit.MoneyValue, to targetCurrency: MoneyKit.CurrencyType) -> AnyPublisher<MoneyKit.MoneyValue, MoneyKit.PriceServiceError> {
        .empty()
    }
}

class MockOnChainTxEngine: OnChainTransactionEngine {

    var walletCurrencyService: MoneyKit.FiatCurrencyServiceAPI = MockFiatCurrencyService()
    var currencyConversionService: PlatformKit.CurrencyConversionServiceAPI = MockCurrencyConversionService()
    var askForRefreshConfirmation: AskForRefreshConfirmation!

    var sourceAccount: Coincore.BlockchainAccount!
    var transactionTarget: Coincore.TransactionTarget!

    var mockPendingTx: PendingTransaction = .init(
        amount: .zero(currency: .bitcoin),
        available: .zero(currency: .bitcoin),
        feeAmount: .zero(currency: .bitcoin),
        feeForFullAvailable: .zero(currency: .bitcoin),
        feeSelection: FeeSelection(selectedLevel: .regular, availableLevels: []),
        selectedFiatCurrency: .GBP
    )

    func assertInputsValid() {}

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> AnyPublisher<PendingTransaction, Error> {
        .just(mockPendingTx)
    }

    var startCalled: Bool = false
    func start(sourceAccount: BlockchainAccount, transactionTarget: TransactionTarget, askForRefreshConfirmation: @escaping AskForRefreshConfirmation) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
        startCalled = true
    }

    var initializeTransactionCalled: (Bool, PendingTransaction?) = (false, nil)
    func initializeTransaction() -> RxSwift.Single<FeatureTransactionDomain.PendingTransaction> {
        initializeTransactionCalled = (true, mockPendingTx)
        return .just(mockPendingTx)
    }

    var updatedAmountCalled: (Bool, PendingTransaction?) = (false, nil)
    func update(amount: MoneyKit.MoneyValue, pendingTransaction: FeatureTransactionDomain.PendingTransaction) -> RxSwift.Single<FeatureTransactionDomain.PendingTransaction> {
        updatedAmountCalled = (true, mockPendingTx)
        return .just(mockPendingTx)
    }

    var validateAmountCalled: (Bool, PendingTransaction?) = (false, nil)
    func validateAmount(pendingTransaction: FeatureTransactionDomain.PendingTransaction) -> RxSwift.Single<FeatureTransactionDomain.PendingTransaction> {
        validateAmountCalled = (true, mockPendingTx)
        return .just(mockPendingTx)
    }

    var doValidateAllCalled: (Bool, PendingTransaction?) = (false, nil)
    func doValidateAll(pendingTransaction: FeatureTransactionDomain.PendingTransaction) -> RxSwift.Single<FeatureTransactionDomain.PendingTransaction> {
        doValidateAllCalled = (true, mockPendingTx)
        return .just(mockPendingTx)
    }

    var executeCalled: Bool = false
    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        executeCalled = true
        return .just(.hashed(txHash: "", amount: nil))
    }

    var doPostExecuteCalled = false
    func doPostExecute(transactionResult: TransactionResult) -> AnyPublisher<Void, Error> {
        doPostExecuteCalled = true
        return .just(())
    }
}
