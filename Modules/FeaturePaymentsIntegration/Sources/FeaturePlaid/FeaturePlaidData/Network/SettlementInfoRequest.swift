// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SettlementInfoRequest: Encodable {
    public struct SettlementRequest: Encodable {
        var amount: String
        var product = "SIMPLEBUY"
    }

    public struct Attributes: Encodable {
        public let settlementRequest: SettlementRequest
    }

    public let attributes: Attributes

    public init(amount: String, product: String) {
        self.attributes = .init(settlementRequest: .init(amount: amount, product: product))
    }
}
