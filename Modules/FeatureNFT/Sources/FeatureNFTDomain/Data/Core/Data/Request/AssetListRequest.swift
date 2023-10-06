import Foundation

struct AssetListRequest: Encodable {
    let network: String
    let address: String
}

extension AssetListRequest {
    static func ethereum(address: String, network: String) -> AssetListRequest {
        .init(network: network, address: address)
    }
}
