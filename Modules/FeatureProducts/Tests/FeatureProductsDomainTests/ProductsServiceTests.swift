import Errors
@testable import FeatureProductsDomain
import TestKit
import ToolKit
import ToolKitMock
import XCTest

final class ProductsServiceTests: XCTestCase {

    private var service: ProductsService!
    private var mockRepository: ProductsRepositoryMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = ProductsRepositoryMock()
        service = ProductsService(
            repository: mockRepository
        )
    }

    override func tearDownWithError() throws {
        service = nil
        mockRepository = nil
        try super.tearDownWithError()
    }

    // MARK: Fetch

    func test_fetch_returns_repositoryError() throws {
        let error = NabuNetworkError.unknown
        try stubRepository(with: error)
        let publisher = service.fetchProducts()
        XCTAssertPublisherError(publisher, .network(error))
    }

    func test_fetch_returns_repositoryValues() throws {
        let expectedProducts = try stubRepositoryWithDefaultProducts()
        XCTAssertPublisherValues(service.fetchProducts(), expectedProducts)
    }

    func test_stream_returns_repositoryError() throws {
        let error = NabuNetworkError.unknown
        try stubRepository(with: error)
        XCTAssertPublisherError(service.fetchProducts(), .network(error))
    }

    // MARK: Stream

    func test_stream_publishes_products() throws {
        let expectedProducts = try stubRepositoryWithDefaultProducts()
        XCTAssertPublisherValues(service.streamProducts(), .success(expectedProducts))
    }

    // MARK: - Private

    private func stubRepository(with error: NabuNetworkError) throws {
        mockRepository.stubbedResponses.fetchProducts = .failure(error)
        mockRepository.stubbedResponses.streamProducts = .just(.failure(error))
    }

    private func stubRepository(with products: Set<ProductValue>) throws {
        mockRepository.stubbedResponses.fetchProducts = .just(products)
        mockRepository.stubbedResponses.streamProducts = .just(.success(products))
    }

    private func stubRepositoryWithDefaultProducts() throws -> Set<ProductValue> {
        let expectedProducts: Set<ProductValue> = [
            ProductValue(
                id: .swap,
                enabled: false,
                maxOrdersCap: 1,
                maxOrdersLeft: 0,
                suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
            ),
            ProductValue(
                id: .sell,
                enabled: false,
                maxOrdersCap: 1,
                maxOrdersLeft: 0,
                suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
            ),
            ProductValue(
                id: .buy,
                enabled: true,
                maxOrdersCap: nil,
                maxOrdersLeft: nil,
                suggestedUpgrade: nil
            )
        ]
        try stubRepository(with: expectedProducts)
        return expectedProducts
    }
}
