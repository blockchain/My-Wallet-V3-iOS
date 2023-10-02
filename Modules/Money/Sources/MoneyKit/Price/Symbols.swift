public struct CurrencySymbols: Decodable, Equatable, Hashable {
    public enum CodingKeys: String, CodingKey {
        case base = "Base", quote = "Quote"
    }

    public let base: [String: CurrencySymbol]
    public let quote: [String: CurrencySymbol]
}

public struct CurrencySymbol: Decodable, Equatable, Hashable {
    public let code: String
    public let description: String
    public let symbol: String
    public let fiat: Bool
}
