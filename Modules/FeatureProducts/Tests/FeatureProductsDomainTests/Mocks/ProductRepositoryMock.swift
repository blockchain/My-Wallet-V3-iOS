import Combine
import Errors
import FeatureProductsDomain
import ToolKit

final class ProductsRepositoryMock: ProductsRepositoryAPI {

    struct RecordedInvocations {
        var fetchProducts: [Void] = []
        var streamProducts: [Void] = []
    }

    struct StubbedResponses {
        var fetchProducts: AnyPublisher<Set<ProductValue>, NabuNetworkError> = .empty()
        var streamProducts: AnyPublisher<Result<Set<ProductValue>, NabuNetworkError>, Never> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResponses = StubbedResponses()

    func fetchProducts() -> AnyPublisher<Set<ProductValue>, NabuNetworkError> {
        recordedInvocations.fetchProducts.append(())
        return stubbedResponses.fetchProducts
    }

    func streamProducts() -> AnyPublisher<Result<Set<ProductValue>, NabuNetworkError>, Never> {
        recordedInvocations.streamProducts.append(())
        return stubbedResponses.streamProducts
    }
}
