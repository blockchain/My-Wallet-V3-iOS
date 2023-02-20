import Blockchain
import PlatformKit

public protocol NabuAccountsRepositoryProtocol {
    func account(type: String, currency: CryptoCurrency) -> AnyPublisher<Nabu.Account, Nabu.Error>
}

extension Nabu {

    public struct Account: Codable {

        public struct Agent: Codable {
            public let main: String?
        }

        public let id, address: String
        public let agent: Agent
        public let currency, state, partner: String
    }
}

extension NabuAccountsRepositoryProtocol {

    public func account(product: HotWalletProduct, currency: CryptoCurrency) -> AnyPublisher<Nabu.Account, Nabu.Error> {
        account(type: product.string, currency: currency)
    }
}
