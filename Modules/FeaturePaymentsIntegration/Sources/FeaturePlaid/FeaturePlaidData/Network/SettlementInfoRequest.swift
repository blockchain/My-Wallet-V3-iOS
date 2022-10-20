// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SettlementInfoRequest: Encodable {
    public struct SettlementRequest: Encodable {
        let product = "SIMPLEBUY"
        let amount: String
    }

    public struct Attributes: Encodable {
        public let settlementRequest: SettlementRequest
    }

    public let attributes: Attributes

    public init(amount: String) {
        attributes = .init(settlementRequest: .init(amount: amount))
    }
}
