import Combine
import DIKit
import Errors
import NetworkKit

protocol ExchangeExperimentsClientAPI {
    func getWalletAwarenessCohort() -> AnyPublisher<WalletAwarenessCohortResponse, NabuNetworkError>
}

final class ExchangeExperimentsClient: ExchangeExperimentsClientAPI {

    private enum Path {
        static let exchangeAddress = ["experiments", "mercury"]
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func getWalletAwarenessCohort() -> AnyPublisher<WalletAwarenessCohortResponse, Errors.NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.exchangeAddress,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
