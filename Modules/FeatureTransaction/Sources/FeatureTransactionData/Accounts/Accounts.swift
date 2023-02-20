import Blockchain
import DIKit
import FeatureTransactionDomain
import NetworkKit
import PlatformKit

public protocol NabuAccountsClientProtocol {
    func account(type: String, currency: CryptoCurrency) -> AnyPublisher<Nabu.Account, Nabu.Error>
}

public typealias NabuAccountsRepository = NabuAccountsClient
extension NabuAccountsRepository: NabuAccountsRepositoryProtocol {}

public final class NabuAccountsClient: NabuAccountsClientProtocol {

    private let network: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    init(
        network: NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
    ) {
        self.network = network
        self.requestBuilder = requestBuilder
    }

    public func account(type: String, currency: CryptoCurrency) -> AnyPublisher<Nabu.Account, Nabu.Error> {
        network.perform(
            request: requestBuilder.put(
                path: "/payments/accounts/\(type)",
                body: try? ["currency": currency.code].data(),
                authenticated: true
            )!
        )
    }
}
