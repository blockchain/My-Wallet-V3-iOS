
public struct Chain: Codable, Equatable {
    public struct NativeCurrency: Codable,Equatable {
        public let symbol: String
        public let name: String
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
