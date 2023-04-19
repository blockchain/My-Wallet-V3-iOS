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
                        let (base, quote) = try (
                            tag.indices[blockchain.api.nabu.gateway.price.crypto.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType,
                            tag.indices[blockchain.api.nabu.gateway.price.crypto.fiat.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType
                        )
                        return service.stream(of: base, in: quote, at: .now)
                            .combineLatest(
                                service.price(of: base, in: quote, at: .oneDay).result()
                            )
                            .map { price, yesterday -> AnyJSON in
                                guard let price = price.success, let yesterday = yesterday.success else { return .empty }
                                var json = L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON()
                                json.currency = base.code
                                json.quote.value = price.moneyValue._data
                                json.quote.timestamp = price.timestamp
                                json.market.cap = price.marketCap
                                json.volume = price.volume24h
                                json.delta.since.yesterday = try? (MoneyValue.delta(yesterday.moneyValue, price.moneyValue) / 100)
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
                        let base = try tag.indices[blockchain.api.nabu.gateway.price.at.time.crypto.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType
                        return try service.stream(
                            of: base,
                            in: tag.indices[blockchain.api.nabu.gateway.price.at.time.crypto.fiat.id].decode(Either<CryptoCurrency, FiatCurrency>.self).currencyType,
                            at: tag.indices[blockchain.api.nabu.gateway.price.at.time.id].decode(PriceTime.self)
                        )
                        .map { price -> AnyJSON in
                            guard let price = price.success else { return .empty }
                            var json = L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON()
                            json.quote.value = price.moneyValue._data
                            json.quote.timestamp = price.timestamp
                            json.market.cap = price.marketCap
                            json.volume = price.volume24h
                            json.currency = base.code
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
        Task {
            try await app.register(
                napi: blockchain.api.nabu.gateway.price,
                domain: blockchain.api.nabu.gateway.price.top.movers,
                repository: { [app] _ in
                    app.publisher(for: blockchain.api.nabu.gateway.simple.buy.pairs.ids, as: [CurrencyPair].self)
                        .replaceError(with: [])
                        .map { pairs -> AnyPublisher<[L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON], Never> in
                            pairs.map { pair in
                                app.publisher(for: blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code], as: blockchain.api.nabu.gateway.price.crypto.fiat)
                                    .replaceError(with: L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON())
                            }
                            .combineLatest()
                        }
                        .switchToLatest()
                        .map { prices -> AnyJSON in
                            AnyJSON(
                                prices.sorted { l, r in
                                    guard let l = l.delta.since.yesterday, let r = r.delta.since.yesterday else { return false }
                                    return abs(l) > abs(r)
                                }
                                .prefix(5)
                                .map(\.currency)
                            )
                        }
                        .eraseToAnyPublisher()
                }
            )
        }
    }

    func stop() {
        ids = nil
    }
}

extension RangeReplaceableCollection {

    private func tuple() throws -> (Element, Element) {
        guard count == 2 else { throw "Not a tuple" }
        return (self[startIndex], self[index(after: startIndex)])
    }
}

extension MoneyValue {

    var _data: [String: Any] {
        ["amount": storeAmount, "currency": code]
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
