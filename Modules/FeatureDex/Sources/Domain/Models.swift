public struct Chain: Codable {

    struct NativeCurrency: Codable {
        let symbol: String
    }

    let chainId: Int64
    let name: String
    let nativeCurrency: NativeCurrency
}

public struct Venue: Codable {
    let type: String
    let name: String
    let title: String
}
