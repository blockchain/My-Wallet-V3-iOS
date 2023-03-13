import Blockchain
import DIKit
import FeatureStakingData
import FeatureStakingDomain

/// TODO: OA - Introduce a lazy repository into namespace so we only fetch and subscribe when a consumer asks for it
/// This would remove this kind of observer and instead model the repository pattern of how the data is fetched and cached
/// Include SQLite storage
class NabuGatewayPriceObserver: Client.Observer {

    private let app: AppProtocol
    private let service: PriceServiceAPI

    private var ids: AnyCancellable?

    init(app: AppProtocol, service: PriceServiceAPI = resolve()) {
        self.app = app
        self.service = service
    }

    func start() {

        ids = app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .sink { [app] currency in
                app.state.transaction { state in
                    state.set(blockchain.api.nabu.gateway.price.crypto.fiat.id, to: currency.code)
                    state.set(blockchain.api.nabu.gateway.price.at.time.crypto.fiat.id, to: currency.code)
                    state.set(blockchain.api.nabu.gateway.price.at.time.id, to: PriceTime.now.id)
                }
            }

        Task {
            try await app.register(
                napi: blockchain.api.nabu.gateway.price,
                domain: blockchain.api.nabu.gateway.price.crypto.fiat,
                repository: { [service] tag in
                    do {
                        return try service.price(
                            of: tag.indices[blockchain.api.nabu.gateway.price.crypto.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType,
                            in: tag.indices[blockchain.api.nabu.gateway.price.crypto.fiat.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType,
                            at: .now
                        )
                        .map { price -> AnyJSON in
                            var json = L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON()
                            json.quote.value = price.moneyValue._data
                            json.quote.timestamp = price.timestamp
                            json.market.cap = price.marketCap
                            json.volume = price.volume24h
                            return json.toJSON()
                        }
                        .replaceError(with: .empty)
                        .eraseToAnyPublisher()
                    } catch {
                        return .just(.empty)
                    }
                }
            )

            try await app.register(
                napi: blockchain.api.nabu.gateway.price,
                domain: blockchain.api.nabu.gateway.price.at.time.crypto.fiat,
                repository: { [service] tag in
                    do {
                        return try service.price(
                            of: tag.indices[blockchain.api.nabu.gateway.price.at.time.crypto.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType,
                            in: tag.indices[blockchain.api.nabu.gateway.price.at.time.crypto.fiat.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType,
                            at: tag.indices[blockchain.api.nabu.gateway.price.at.time.id].decode(PriceTime.self)
                        )
                        .map { price -> AnyJSON in
                            var json = L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON()
                            json.quote.value = price.moneyValue._data
                            json.quote.timestamp = price.timestamp
                            json.market.cap = price.marketCap
                            json.volume = price.volume24h
                            return json.toJSON()
                        }
                        .replaceError(with: .empty)
                        .eraseToAnyPublisher()
                    } catch {
                        return .just(.empty)
                    }
                }
            )
        }
    }

    func stop() {
        ids = nil
    }
}

extension RangeReplaceableCollection {

    fileprivate func tuple() throws -> (Element, Element) {
        guard count == 2 else { throw "Not a tuple" }
        return (self[startIndex], self[index(after: startIndex)])
    }
}

extension MoneyValue {

    var _data: [String: Any] {
        ["amount": minorString, "currency": code]
    }
}

extension Either<CryptoCurrency, FiatCurrency> {
    var currencyType: CurrencyType {
        switch self {
        case .left(let a): return a.currencyType
        case .right(let b): return b.currencyType
        }
    }
}
