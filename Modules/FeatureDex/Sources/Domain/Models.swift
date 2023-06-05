public struct Chain: Codable, Equatable {
    public struct NativeCurrency: Codable,Equatable {
        let symbol: String
    }

    public let chainId: Int64
    public let name: String
    public let nativeCurrency: NativeCurrency
}

public struct Venue: Codable {
    let type: String
    let name: String
    let title: String
}
