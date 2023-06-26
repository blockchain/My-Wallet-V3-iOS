public struct Chain: Decodable, Equatable {
    public let chainId: Int64

    public init(chainId: Int64) {
        self.chainId = chainId
    }
}
