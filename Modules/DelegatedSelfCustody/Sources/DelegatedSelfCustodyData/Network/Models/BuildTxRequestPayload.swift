// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import ToolKit

struct BuildTxRequestPayload: Encodable {
    struct SwapTx: Encodable {
        let data: String
        let gasLimit: String
        let value: String
    }

    struct ExtraData: Encodable {
        let memo: String
        let feeCurrency: String
        let spender: String?
        let swapTx: SwapTx?
    }

    let account: Int
    let amount: String?
    let auth: AuthDataPayload
    let currency: String
    let destination: String
    let extraData: ExtraData
    let fee: String
    let maxVerificationVersion: Int?
    let type: String

    init(
        input: DelegatedCustodyTransactionInput,
        guidHash: String,
        sharedKeyHash: String
    ) {
        self.account = input.account
        self.amount = input.amount?.stringValue
        self.auth = AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash)
        self.currency = input.currency
        self.destination = input.destination
        self.extraData = ExtraData(
            memo: input.memo,
            feeCurrency: input.feeCurrency,
            spender: input.type.allowanceSpender,
            swapTx: input.type.swapTransaction
        )
        self.fee = input.fee.stringValue
        self.maxVerificationVersion = input.maxVerificationVersion?.rawValue
        self.type = input.type.type
    }
}

extension DelegatedCustodyTransactionType {
    var swapTransaction: BuildTxRequestPayload.SwapTx? {
        switch self {
        case .payment:
            nil
        case .swap(let data, let gasLimit, let value):
            BuildTxRequestPayload.SwapTx(
                data: data,
                gasLimit: gasLimit,
                value: value
            )
        case .tokenApproval:
            nil
        }
    }
}

extension DelegatedCustodyFee {
    var stringValue: String {
        switch self {
        case .low:
            "LOW"
        case .normal:
            "NORMAL"
        case .high:
            "HIGH"
        case .custom(let value):
            value
        }
    }
}

extension DelegatedCustodyAmount {
    var stringValue: String {
        switch self {
        case .max:
            "MAX"
        case .custom(let value):
            value
        }
    }
}
