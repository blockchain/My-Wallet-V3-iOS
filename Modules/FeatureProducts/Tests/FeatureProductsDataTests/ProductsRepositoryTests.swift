import Errors
@testable import FeatureProductsData
import FeatureProductsDomain
import TestKit
import ToolKit
import XCTest

final class ProductsRepositoryTests: XCTestCase {

    private var repository: ProductsRepository!
    private var mockClient: ProductsClientMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClient = ProductsClientMock()
        repository = ProductsRepository(client: mockClient)
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

    func test_returnsProducts() throws {
        let expectedProducts = try stubClientWithDefaultProducts()
        let publisher = repository.fetchProducts()
        XCTAssertPublisherValues(publisher, expectedProducts)
    }

    func test_cache_validCache() throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(firstRequestPublisher, expectedProducts)
        // WHEN: A second request is fired
        let secondRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(secondRequestPublisher, expectedProducts)
        // THEN: The repository has used the cache to serve the response
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 1)
    }

    func test_cache_invalidatesCacheOn_transactionNotification() throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(firstRequestPublisher, expectedProducts)
        // WHEN: The cache should be invalidated
        NotificationCenter.default.post(name: .transaction, object: nil)
        // AND: A second request is fired
        let secondRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(secondRequestPublisher, expectedProducts)
        // THEN: The repository has NOT used the cache to serve the response
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    func test_cache_invalidatesCacheOn_kycStatusChangedNotification() throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(firstRequestPublisher, expectedProducts)
        // WHEN: The cache should be invalidated
        NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
        // AND: A second request is fired
        let secondRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(secondRequestPublisher, expectedProducts)
        // THEN: The repository has NOT used the cache to serve the response
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    func test_stream_publishesNewValues_whenCacheIsInvalidated() throws {
        // GIVEN: A stream is requested
        let expectedProducts = try stubClientWithDefaultProducts()
        let publisher = repository.streamProducts()
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        // WHEN: The cache is invalidated
        NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
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
        NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
        // AND: Valid data is available
        let expectedProducts = try stubClientWithDefaultProducts()
        // THEN: The data is refreashed
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        XCTAssertEqual(mockClient.recordedInvocations.fetchProductsData.count, 2)
    }

    // MARK: - Helpers

    private func stubClientWithDefaultProducts() throws -> [ProductValue] {
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
        let stubbedResponse = try ProductsAPIResponse(json: stubbedResponseData.json())
        mockClient.stubbedResults.fetchProductsData = .just(stubbedResponse)
    }

    private func stubClientProductsDataResponse(with error: NabuNetworkError) throws {
        mockClient.stubbedResults.fetchProductsData = .failure(error)
    }
}
