import Blockchain
import DIKit
import FeatureTransactionDomain
import NetworkKit
import PlatformKit
import ToolKit

public protocol NabuAccountsClientProtocol {
    func account(type: String, currency: CryptoCurrency) -> AnyPublisher<Nabu.Account, Nabu.Error>
}

public final class NabuAccountsRepository: NabuAccountsRepositoryProtocol {

    struct Key: Hashable {
        let type: String
        let currency: CryptoCurrency
    }

    let client: NabuAccountsClientProtocol
    let cache: CachedValueNew<NabuAccountsRepository.Key, Nabu.Account, Nabu.Error>

    init(client: NabuAccountsClientProtocol) {
        self.client = client
        self.cache = CachedValueNew(
            cache: InMemoryCache(configuration: .onLoginLogout(), refreshControl: PerpetualCacheRefreshControl()).eraseToAnyCache(),
            fetch: { [client] key in client.account(type: key.type, currency: key.currency) }
        )
    }

    public func account(type: String, currency: CryptoCurrency) -> AnyPublisher<Nabu.Account, Nabu.Error> {
        cache.get(key: Key(type: type, currency: currency))
    }
}

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
