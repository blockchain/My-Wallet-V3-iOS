// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

struct NetworkConfigResponse: Codable {
    let networks: [Network]
    let types: [TypeEntry]
}

extension NetworkConfigResponse {

    struct NetworkType: NewTypeString {
        let value: String
        init(_ value: String) { self.value = value }
        static let bch: Self = "BCH"
        static let btc: Self = "BTC"
        static let evm: Self = "EVM"
        static let sol: Self = "SOL"
        static let stx: Self = "STX"
        static let xlm: Self = "XLM"
    }

    struct NetworkProduct: NewTypeString {
        let value: String
        init(_ value: String) { self.value = value }
        static let dscData: Self = "DSC_DATA"
        static let dscTransactions: Self = "DSC_TRANSACTIONS"
    }

    struct Network: Codable {
        let explorerUrl: String
        let identifiers: JSONValue
        let name: String
        let nativeAsset: String
        let networkTicker: String
        let nodeUrls: [String]?
        let shortName: String
        let supportedBy: [NetworkProduct]
        let type: NetworkType
    }

    struct TypeEntry: Codable {

        struct Style: NewTypeString {
            let value: String
            init(_ value: String) { self.value = value }
            static let single: Self = "SINGLE"
            static let extended: Self = "EXTENDED"
        }

        struct Derivation: Codable {
            let purpose: Int
            let coinType: Int
            let descriptor: Int
        }

        let type: NetworkType
        let derivations: [Derivation]
        let style: Style
    }
}
