public struct Chain: Codable, Equatable {
    public init(chainId: Int64, name: String, nativeCurrency: Chain.NativeCurrency) {
        self.chainId = chainId
        self.name = name
        self.nativeCurrency = nativeCurrency
    }

    public struct NativeCurrency: Codable, Equatable {
        public init(symbol: String, name: String) {
            self.symbol = symbol
            self.name = name
        }

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
