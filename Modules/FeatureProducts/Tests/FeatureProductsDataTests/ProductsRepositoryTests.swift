import AnyCoding
import Blockchain
import Errors
@testable import FeatureProductsData
import FeatureProductsDomain
import TestKit
import ToolKit
import XCTest

@MainActor final class ProductsRepositoryTests: XCTestCase {

    private var app: AppProtocol!
    private var repository: ProductsRepository!
    private var mockClient: ProductsClientMock!

    override func setUp() async throws {
        try await super.setUp()
        app = App.test
        app.signIn(userId: "test")
        try await app.set(blockchain.user.is.external.brokerage, to: false)
        mockClient = ProductsClientMock()
        repository = ProductsRepository(app: app, client: mockClient)
    }

    override func tearDownWithError() throws {
        repository = nil
        mockClient = nil
        try super.tearDownWithError()
    }

    func test_returnsError() throws {
        let error = NabuNetworkError.unknown
        try stubClientProductsDataResponse(with: error)
        let publisher = repository.fetchProducts()
        XCTAssertPublisherError(publisher, error)
    }

    func test_returnsProducts() async throws {
        let expectedProducts = try stubClientWithDefaultProducts()
        let products = try await repository.fetchProducts().await()
        XCTAssertEqual(products, expectedProducts)
    }

    func test_cache_validCache() async throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstProducts = try await repository.fetchProducts().await()
        XCTAssertEqual(firstProducts, expectedProducts)
        // WHEN: A second request is fired
        let secondProducts = try await repository.fetchProducts().await()
        XCTAssertEqual(secondProducts, expectedProducts)
        // THEN: The repository has used the cache to serve the response
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 1)
    }

    func test_cache_invalidatesCacheOn_transactionNotification() async throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstProducts = try await repository.fetchProducts().await()
        XCTAssertEqual(firstProducts, expectedProducts)
        // WHEN: The cache should be invalidated
        app.post(event: blockchain.ux.transaction.event.did.finish)
        // AND: A second request is fired
        let secondProducts = try await repository.fetchProducts().await()
        XCTAssertEqual(secondProducts, expectedProducts)
        // THEN: The repository has NOT used the cache to serve the response
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    func test_cache_invalidatesCacheOn_kycStatusChangedNotification() async throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstProducts = try await repository.fetchProducts().await()
        XCTAssertEqual(firstProducts, expectedProducts)
        // WHEN: The cache should be invalidated
        app.post(event: blockchain.ux.kyc.event.status.did.change)
        // AND: A second request is fired
        let secondProducts = try await repository.fetchProducts().await()
        XCTAssertEqual(secondProducts, expectedProducts)
        // THEN: The repository has NOT used the cache to serve the response
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    func test_stream_publishesNewValues_whenCacheIsInvalidated() async throws {
        // GIVEN: A stream is requested
        let expectedProducts = try stubClientWithDefaultProducts()
        let publisher = repository.streamProducts()
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        // WHEN: The cache is invalidated
        app.post(event: blockchain.ux.transaction.event.did.finish)
        try await Task.sleep(nanoseconds: 1)
        // AND: The data is refreashed
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    func test_stream_doesNotFailOnFailure() throws {
        // GIVEN: The stream returns an error
        let error = NabuNetworkError.unknown
        try stubClientProductsDataResponse(with: error)
        // WHEN: A stream is requested
        let publisher = repository.streamProducts()
        // THEN: The failure is returned
        XCTAssertPublisherValues(publisher, .failure(error), expectCompletion: false)
        // WHEN: The cache is invalidated
        app.post(event: blockchain.ux.transaction.event.did.finish)
        // AND: Valid data is available
        let expectedProducts = try stubClientWithDefaultProducts()
        // THEN: The data is refreashed
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    // MARK: - Helpers

    private func stubClientWithDefaultProducts() throws -> Set<ProductValue> {
        // stub using local file
        try stubClientProductsDataResponse(usingFileNamed: "stub_products")
        // return expected products from parsing the file
        return [
            ProductValue(
                id: .buy,
                enabled: true
            ),
            ProductValue(
                id: .sell,
                enabled: false,
                maxOrdersCap: 1,
                maxOrdersLeft: 0,
                suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
            ),
            ProductValue(
                id: .swap,
                enabled: true,
                maxOrdersCap: 1,
                maxOrdersLeft: 0
            ),
            ProductValue(
                id: .trade,
                enabled: false
            ),
            ProductValue(
                id: .depositFiat,
                enabled: false,
                reasonNotEligible: ProductIneligibility(type: .sanction, message: "Error message", reason: .eu5Sanction)
            ),
            ProductValue(
                id: .depositCrypto,
                enabled: false
            ),
            ProductValue(
                id: .depositEarnCC1W,
                enabled: true
            ),
            ProductValue(
                id: .depositInterest,
                enabled: false
            ),
            ProductValue(
                id: .depositStaking,
                enabled: true
            ),
            ProductValue(
                id: .withdrawFiat,
                enabled: true
            ),
            ProductValue(
                id: .withdrawCrypto,
                enabled: true
            ),
            ProductValue(
                id: .useTradingAccount,
                enabled: true
            )
        ]
    }

    private func stubClientProductsDataResponse(usingFileNamed fileName: String) throws {
        enum FixtureError: Error {
            case fileNotFound
        }

        guard let stubbedResponseURL = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            throw FixtureError.fileNotFound
        }
        let stubbedResponseData = try Data(contentsOf: stubbedResponseURL)
        let stubbedResponseJSON = try JSONSerialization.jsonObject(with: stubbedResponseData)
        let stubbedResponse = try AnyDecoder().decode([String: ProductValue?].self, from: stubbedResponseJSON)
        mockClient.stubbedResults.fetchProductsData = .just(stubbedResponse)
    }

    private func stubClientProductsDataResponse(with error: NabuNetworkError) throws {
        mockClient.stubbedResults.fetchProductsData = .failure(error)
    }
}
