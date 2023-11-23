import Blockchain
import NetworkKit

public struct IntercomIdentity: Decodable {
    public let digest: String
}

public class GetIntercomIdentity {

    let adapter: NetworkAdapterAPI
    let request: RequestBuilder

    public init(adapter: NetworkAdapterAPI, request: RequestBuilder) {
        self.adapter = adapter
        self.request = request
    }

    public func getUserIntercomIdentity() async throws -> IntercomIdentity {
        try await adapter.perform(
            request: request.get(path: "/user/intercom/identity", authenticated: true)!
        )
        .await()
    }
}

public class IntercomIdentityNAPI {

    @Dependency(\.app) var app

    let client: GetIntercomIdentity

    public init(client: GetIntercomIdentity) {
        self.client = client
    }

    public func register() async throws {
        try await app.register(
            napi: blockchain.api.nabu.gateway.user,
            domain: blockchain.api.nabu.gateway.user.intercom.identity.user.digest,
            repository: { [client] _ async -> AnyJSON in
                do {
                    return try await AnyJSON(client.getUserIntercomIdentity().digest)
                } catch {
                    return AnyJSON(error)
                }
            }
        )
    }

}
