import Blockchain
import NetworkKit

class NewsNAPIRepository: CustomStringConvertible {

    let session = URLSession.shared

    let network: NetworkAdapterAPI = DIKit.resolve()
    let decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(NetworkResponseDecoder.anyDecoder)
    let request: RequestBuilder = RequestBuilder(
        config: Network.Config(
            scheme: "https",
            host: "api.blockchain.info"
        )
    )

    func register(_ app: AppProtocol) async throws {

        try await app.register(
            napi: blockchain.api.news,
            domain: blockchain.api.news.all,
            repository: { [network, request, decoder] tag in
                network.perform(
                    request: request.get(path: ["news", "articles"], decoder: decoder)!,
                    responseType: AnyJSON.self
                )
                .map { data in My.map(tag: tag, data: data) }
                .replaceError(with: .empty)
                .eraseToAnyPublisher()
            }
        )

        try await app.register(
            napi: blockchain.api.news,
            domain: blockchain.api.news.asset,
            repository: { [network, request, decoder] tag in
                do {
                    let assets = try tag.indices[blockchain.api.news.asset.id].decode(String.self)
                    return network.perform(
                        request: request.get(
                            path: ["news", "articles"],
                            parameters: [URLQueryItem(name: "assets", value: assets)],
                            decoder: decoder
                        )!,
                        responseType: AnyJSON.self
                    )
                    .map { data in My.map(tag: tag, data: data) }
                    .replaceError(with: .empty)
                    .eraseToAnyPublisher()
                } catch {
                    return Just(AnyJSON.empty).eraseToAnyPublisher()
                }
            }
        )
    }

    static func map(tag: Tag.Reference, data: AnyJSON) -> AnyJSON {
        var news = L_blockchain_api_news_asset.JSON(in: tag.context)
        news.cursor = data.cursor
        news.is.tail = data.isTail
        if let articles = try? data.articles.as([[String: Any]].self) {
            var ids: [String] = []
            for article in articles {
                guard let id = try? article["id"].decode(String.self) else { continue }
                ids.append(id)
                news.article[id] = article
            }
            news.articles = ids
        }
        return news.toJSON()
    }

    var description: String { "news" }
}
