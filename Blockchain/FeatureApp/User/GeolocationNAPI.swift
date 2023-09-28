import Blockchain
import DIKit
import NetworkKit

func registerGeolocationNAPI() async throws {
    let client = GeolocationClient()
    try await app.register(
        napi: blockchain.api.nabu.gateway.geo,
        domain: blockchain.api.nabu.gateway.geo.location,
        repository: { tag in
            do {
                let response = try await client.geolocation()
                var json = L_blockchain_api_nabu_gateway_geo_location.JSON()
                json.ip = response.ip
                json.country.code = response.countryCode
                json.header.city = response.headerCFIpCity
                json.header.continent = response.headerCFIpCountry
                json.header.country = response.headerCFIpContinent
                json.header.longitude = response.headerCFIpLongitude
                json.header.latitude = response.headerCFIpLatitude
                return json.toJSON()
            } catch {
                return AnyJSON(error)
            }
        }
    )
}

private struct Geolocation: Decodable {
    var ip, countryCode: String?
    var headerCFIpCity, headerCFIpCountry, headerCFIpContinent: String?
    var headerCFIpLongitude, headerCFIpLatitude: String?
}


private class GeolocationClient {

    let adapter: NetworkAdapterAPI
    let requestBuilder: RequestBuilder

    init(
        adapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.adapter = adapter
        self.requestBuilder = requestBuilder
    }

    func geolocation() async throws -> Geolocation {
        try await adapter.perform(
            request: requestBuilder.get(
                path: "/geolocation2",
                authenticated: false
            )!
        )
        .await()
    }
}
