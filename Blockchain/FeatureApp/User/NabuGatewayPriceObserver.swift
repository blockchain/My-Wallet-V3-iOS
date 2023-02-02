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

    private var yesterday, now: AnyCancellable?, task: Task<Void, Never>?

    init(app: AppProtocol, service: PriceServiceAPI = resolve()) {
        self.app = app
        self.service = service
    }

    func start() {
        now = app
            .publisher(
                for: blockchain.user.currency.preferred.fiat.display.currency,
                as: FiatCurrency.self
            )
            .compactMap(\.value)
            .handleEvents(
                receiveOutput: { [app] currency in
                    app.state.transaction { state in
                        state.set(blockchain.api.nabu.gateway.price.crypto.fiat.id, to: currency.code)
                        state.set(blockchain.api.nabu.gateway.price.at.time.id, to: PriceTime.now.id)
                    }
                }
            )
            .flatMap { [service] currency in
                service.stream(quote: currency, at: .now, skipStale: true)
            }
            .sink(to: My.now, on: self)

        yesterday = app
            .publisher(
                for: blockchain.user.currency.preferred.fiat.display.currency,
                as: FiatCurrency.self
            )
            .compactMap(\.value)
            .handleEvents(
                receiveOutput: { [app] currency in
                    app.state.transaction { state in
                        state.set(blockchain.api.nabu.gateway.price.at.time.crypto.fiat.id, to: currency.code)
                    }
                }
            )
            .flatMap { [service] currency in
                service.stream(quote: currency, at: .oneDay, skipStale: true)
            }
            .sink(to: My.yesterday, on: self)
    }

    func stop() {
        yesterday = nil
        now = nil
        task = nil
    }

    func now(_ result: Result<[String: PriceQuoteAtTime], NetworkError>) {
        let time = PriceTime.now
        task = Task {
            do {
                var batch = App.BatchUpdates()
                for (pair, quote) in try result.get() {
                    let (crypto, fiat) = try pair.split(separator: "-").map(\.string).tuple()
                    batch.append((blockchain.api.nabu.gateway.price.crypto[crypto].fiat[fiat].quote.value, quote.moneyValue._data))
                    batch.append((blockchain.api.nabu.gateway.price.crypto[crypto].fiat[fiat].quote.timestamp, quote.timestamp))
                    batch.append((blockchain.api.nabu.gateway.price.crypto[crypto].fiat[fiat].market.cap, quote.marketCap))
                    batch.append((blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto].fiat[fiat].quote.value, quote.moneyValue._data))
                    batch.append((blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto].fiat[fiat].quote.timestamp, quote.timestamp))
                    batch.append((blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto].fiat[fiat].market.cap, quote.marketCap))
                }
                try await app.batch(updates: batch)
            } catch {
                app.post(error: error)
            }
        }
    }

    func yesterday(_ result: Result<[String: PriceQuoteAtTime], NetworkError>) {
        let time = PriceTime.oneDay
        task = Task {
            do {
                var batch = App.BatchUpdates()
                for (pair, quote) in try result.get() {
                    let (crypto, fiat) = try pair.split(separator: "-").map(\.string).tuple()
                    batch.append((blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto].fiat[fiat].quote.value, quote.moneyValue._data))
                    batch.append((blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto].fiat[fiat].quote.timestamp, quote.timestamp))
                    batch.append((blockchain.api.nabu.gateway.price.at.time[time.id].crypto[crypto].fiat[fiat].market.cap, quote.marketCap))
                }
                try await app.batch(updates: batch)
            } catch {
                app.post(error: error)
            }
        }
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
