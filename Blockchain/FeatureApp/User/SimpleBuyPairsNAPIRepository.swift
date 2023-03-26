import Blockchain
import NetworkKit
import PlatformKit

class SimpleBuyPairsNAPIRepository: CustomStringConvertible, ClientObserver {

    let app: AppProtocol
    let service: SupportedPairsServiceAPI
    let session: URLSession

    var subscription: AnyCancellable?

    init(
        _ app: AppProtocol,
        _ service: SupportedPairsServiceAPI = resolve(),
        _ session: URLSession = .shared
    ) {
        self.app = app
        self.service = service
        self.session = session
    }

    func start() {
        subscription = app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: String.self)
            .sink { [app] currency in
                app.state.transaction { state in
                    try state.set(blockchain.api.nabu.gateway.simple.buy.currency, to: currency.get())
                }
            }
        Task {
            do {
                try await register(app)
            } catch {
                app.post(error: error)
            }
        }
    }

    func stop() {
        subscription = nil
    }

    func register(_ app: AppProtocol) async throws {

        try await app.register(
            napi: blockchain.api.nabu.gateway.simple,
            domain: blockchain.api.nabu.gateway.simple.buy.pairs,
            repository: { [app, service] tag in
                app.publisher(for: blockchain.api.nabu.gateway.simple.buy.currency, as: FiatCurrency.self)
                    .map { currency in
                        service.fetchPairs(for: currency.value.map { .only(fiatCurrency: $0) } ?? .all)
                            .map { [self] data in map(tag: tag, data: data) }
                            .replaceError(with: .empty)
                            .eraseToAnyPublisher()
                    }
                    .switchToLatest()
                    .eraseToAnyPublisher()
            }
        )
    }

    func map(tag: Tag.Reference, data: SupportedPairs) -> AnyJSON {
        var buy = L_blockchain_api_nabu_gateway_simple_buy_pairs.JSON()
        buy.ids = data.pairs.map(\.string)
        for value in data.pairs {
            buy.pair[value.string].buy.min = value.minFiatValue.moneyValue._data
            buy.pair[value.string].buy.max = value.maxFiatValue.moneyValue._data
        }
        return buy.toJSON()
    }

    var description: String { "simple-buy/pairs" }
}
