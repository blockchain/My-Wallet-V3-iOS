// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import ToolKit

struct BuildTxRequestPayload: Encodable {
    struct ExtraData: Encodable {
        let memo: String
        let feeCurrency: String
    }

    let account: Int
    let amount: String
    let auth: AuthDataPayload
    let currency: String
    let destination: String
    let extraData: ExtraData
    let fee: String
    let maxVerificationVersion: Int?
    let spender: String?
    let swapTx: JSONValue?
    let type: String

    init(
        input: DelegatedCustodyTransactionInput,
        guidHash: String,
        sharedKeyHash: String
    ) {
        self.account = input.account
        self.amount = input.amount.stringValue
        self.auth = AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash)
        self.currency = input.currency
        self.destination = input.destination
        self.extraData = ExtraData(memo: input.memo, feeCurrency: input.feeCurrency)
        self.fee = input.fee.stringValue
        self.maxVerificationVersion = input.maxVerificationVersion?.rawValue
        self.spender = input.type.spender
        self.swapTx = input.type.swapTransaction
        self.type = input.type.type
    }
}

extension DelegatedCustodyFee {
    var stringValue: String {
        switch self {
        case .low:
            return "LOW"
        case .normal:
            return "NORMAL"
        case .high:
            return "HIGH"
        case .custom(let value):
            return value
        }
    }
}

extension DelegatedCustodyAmount {
    var stringValue: String {
        switch self {
        case .max:
            return "MAX"
        case .custom(let value):
            return value
        }
    }
}
