public struct Chain: Codable, Equatable {

    struct NativeCurrency: Codable,Equatable {
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
