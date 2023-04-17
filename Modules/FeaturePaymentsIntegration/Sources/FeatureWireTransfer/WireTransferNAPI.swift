import AnyCoding
import Blockchain
import DIKit
import NetworkKit

public final class WireTransferNAPI {

    unowned let app: AppProtocol

    // TODO: remove DIKit
    let network: NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
    let decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(NetworkResponseDecoder.anyDecoder)
    let request: RequestBuilder = resolve(tag: DIKitContext.retail)

    public init(_ app: AppProtocol) {
        self.app = app
    }

    // TODO:
    public func register() async throws {

        try await app.register(
            napi: blockchain.api.nabu.gateway.payments.accounts,
            domain: blockchain.api.nabu.gateway.payments.accounts.simple.buy,
            repository: { [network, request, decoder] tag async -> AnyJSON in
                do {
                    let currency = try tag[blockchain.api.nabu.gateway.payments.accounts.simple.buy.id].decode(String.self)
                    return try await network.perform(
                        request: request.put(
                            path: ["payments", "accounts", "simplebuy"],
                            body: ["currency": currency].json(),
                            authenticated: true,
                            decoder: decoder
                        )!,
                        responseType: AnyJSON.self
                    )
                    .tryMap(self.transform(currency))
                    .await()
                } catch {
                    return AnyJSON(error)
                }
            }
        )
    }

    func transform(_ currency: String) -> (_ json: AnyJSON) throws -> AnyJSON {
        { json in
            var data: Any? = [:] as [String: Any]
            data["title"] = "Add a \(currency) Bank"

            let headers = json["content", "headers"] as? [Any?] ?? []
            let sections = json["content", "sections"] as? [Any?] ?? []
            let footers = json["content", "footers"] as? [Any?] ?? []

            if headers.isEmpty, sections.isEmpty, footers.isEmpty {
                throw "No content"
            }

            for (i, header) in headers.enumerated() {
                var header = header
                header["value"] = header["message"]
                header["important"] = header["isImportant"]
                data["content", "header", AnyCodingKey(i)] = header
            }

            for (i, footer) in footers.enumerated() {
                var footer = footer
                footer["value"] = footer["message"]
                footer["important"] = footer["isImportant"]
                data["content", "footer", AnyCodingKey(i)] = footer
            }

            data["content", "sections"] = sections.map(\.["name"])

            for section in sections {
                guard let id = section["name"] as? String else { continue }
                var section = section
                section["title"] = section["name"]

                let rows = section["entries"] as? [Any?] ?? []
                section["rows"] = rows.map(\.["id"])

                for row in rows {
                    guard let id = row["id"] as? String else { continue }
                    var row = row
                    row["value"] = row["message"]
                    row["important"] = row["isImportant"]
                    row["button", "help", "event", "select", "then", "enter", "into"] = blockchain.ux.payment.method.wire.transfer.help(\.id)
                    row["button", "copy", "event", "select", "then", "copy"] = row["value"]
                    section["row", id] = row
                }
                data["content", "section", id] = section
            }

            return AnyJSON(data)
        }
    }
}
