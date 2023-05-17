// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

enum SignatureAlgorithmResponse: String, Codable {
    case secp256k1
}

struct BuildTxResponse: Decodable {
    struct Summary: Decodable {
        let relativeFee: String
        let absoluteFeeMaximum: String
        let absoluteFeeEstimate: String
        let amount: String?
        let balance: String?
    }

    struct PreImage: Decodable {
        let preImage: String
        let signingKey: String
        let descriptor: String?
        let signatureAlgorithm: SignatureAlgorithmResponse
    }

    let summary: Summary
    let rawTx: JSONValue
    let preImages: [PreImage]
}
