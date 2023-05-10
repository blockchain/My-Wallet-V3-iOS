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
        account = input.account
        amount = input.amount.stringValue
        auth = AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash)
        currency = input.currency
        destination = input.destination
        extraData = ExtraData(memo: input.memo, feeCurrency: input.feeCurrency)
        fee = input.fee.stringValue
        maxVerificationVersion = input.maxVerificationVersion?.rawValue
        spender = input.type.spender
        swapTx = input.type.swapTransaction
        type = input.type.type
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
