// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20DataKit
@testable import ERC20DataKitMock
import ERC20Kit
@testable import ERC20KitMock
import EthereumKit
import MoneyKit
@testable import MoneyKitMock
import PlatformKit
@testable import PlatformKitMock
import TestKit
import ToolKit
import XCTest

final class ERC20BalancesRepositoryTests: XCTestCase {

    // MARK: - Private Properties

    private let refreshInterval: TimeInterval = 3
    private let currency: CryptoCurrency = .mockERC20(symbol: "A", displaySymbol: "A", name: "ERC20 1", sortIndex: 0)
    private let ethereumAddress = EthereumAddress(address: "0x0000000000000000000000000000000000000000", network: .ethereum)!

    private var fetchAccounts: ERC20TokenAccounts!
    private var client: ERC20BalancesClientMock!
    private var cache: AnyCache<ERC20BalancesRepository.ERC20TokenAccountsKey, ERC20TokenAccounts>!
    private var subject: ERC20BalancesRepositoryAPI!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        client = ERC20BalancesClientMock(
            cryptoCurrency: currency,
            behaviour: .succeed
        )

        fetchAccounts = .stubbed(cryptoCurrency: currency)

        let refreshControl = PeriodicCacheRefreshControl(refreshInterval: refreshInterval)
        cache = InMemoryCache(
            configuration: .default(),
            refreshControl: refreshControl
        )
        .eraseToAnyCache()

        let enabledCurrenciesService = MockEnabledCurrenciesService()
        enabledCurrenciesService.allEnabledEVMNetworks = [.ethereum]
        enabledCurrenciesService.allEnabledCryptoCurrencies = [currency]

        subject = ERC20BalancesRepository(
            client: client,
            cache: cache,
            enabledCurrenciesService: enabledCurrenciesService
        )
    }

    override func tearDown() {
        fetchAccounts = nil
        cache = nil
        client = nil
        subject = nil
        super.tearDown()
    }

    // MARK: - Tokens

    func test_tokens_absentAddress() {
        // GIVEN: an address with no value associated
        let address = ethereumAddress

        let expectedValue: ERC20TokenAccounts = fetchAccounts

        // WHEN: getting the tokens for that address
        let publisher = subject.tokens(for: address.publicKey, network: .ethereum, forceFetch: false)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_tokens_staleAddress() {
        // GIVEN: an address with a stale value associated
        let address = ethereumAddress
        let key = ERC20BalancesRepository.ERC20TokenAccountsKey(address: address.publicKey, network: .ethereum)
        let newValue: ERC20TokenAccounts = [
            currency: .init(balance: .one(currency: currency))
        ]

        let expectedValue: ERC20TokenAccounts = fetchAccounts

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // Wait for set value to become stale.
        Thread.sleep(forTimeInterval: refreshInterval)

        // WHEN: getting the tokens for that address
        let publisher = subject.tokens(for: address.publicKey, network: .ethereum, forceFetch: false)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_tokens_presentAddress() {
        // GIVEN: an address with a present value associated
        let address = ethereumAddress
        let key = ERC20BalancesRepository.ERC20TokenAccountsKey(address: address.publicKey, network: .ethereum)
        let newValue: ERC20TokenAccounts = [
            currency: .init(balance: .one(currency: currency))
        ]

        let expectedValue: ERC20TokenAccounts = newValue

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // WHEN: getting the tokens for that address
        let publisher = subject.tokens(for: address.publicKey, network: .ethereum, forceFetch: false)

        // THEN: the present value is returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_tokens_forceFetch() {
        // GIVEN: an address with a present value associated
        let address = ethereumAddress
        let key = ERC20BalancesRepository.ERC20TokenAccountsKey(address: address.publicKey, network: .ethereum)
        let newValue: ERC20TokenAccounts = [
            currency: .init(balance: .one(currency: currency))
        ]

        let expectedValue: ERC20TokenAccounts = fetchAccounts

        let cacheSetPublisher = cache.set(newValue, for: key)

        XCTAssertPublisherCompletion(cacheSetPublisher)

        // WHEN: getting the tokens for that address with force fetch
        let publisher = subject.tokens(for: address.publicKey, network: .ethereum, forceFetch: true)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }

    func test_tokens_retry() {
        // GIVEN: fetching fails, and an address with no value associated
        client.behaviour = .failThenSucceed
        let address = ethereumAddress

        let expectedValue: ERC20TokenAccounts = fetchAccounts

        // WHEN: getting the tokens for that address
        let publisher = subject.tokens(for: address.publicKey, network: .ethereum, forceFetch: true)

        // THEN: a new value is fetched and returned
        XCTAssertPublisherValues(publisher, expectedValue)
    }
}
