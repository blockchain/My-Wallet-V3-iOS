import Combine
import Errors
import FeatureProductsData
import FeatureProductsDomain
import ToolKit

final class ProductsClientMock: ProductsClientAPI {

    struct RecordedInvocations {
        var fetchProductsData: [Void] = []
    }

    struct StubbedResults {
        var fetchProductsData: AnyPublisher<[String: ProductValue?], NabuNetworkError> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func fetchProductsData() -> AnyPublisher<[String: ProductValue?], NabuNetworkError> {
        recordedInvocations.fetchProductsData.append(())
        return stubbedResults.fetchProductsData
    }
}
