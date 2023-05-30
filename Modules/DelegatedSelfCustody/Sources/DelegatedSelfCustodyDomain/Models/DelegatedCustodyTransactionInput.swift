// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct DelegatedCustodyTransactionInput: Hashable {

    public enum VerificationVersion: Int {
        case v1 = 1
    }

    public let account: Int
    public let amount: DelegatedCustodyAmount?
    public let currency: String
    public let destination: String
    public let fee: DelegatedCustodyFee
    public let feeCurrency: String
    public let maxVerificationVersion: VerificationVersion?
    public let memo: String
    public let type: DelegatedCustodyTransactionType

    public init(
        account: Int,
        amount: DelegatedCustodyAmount?,
        currency: String,
        destination: String,
        fee: DelegatedCustodyFee,
        feeCurrency: String,
        maxVerificationVersion: VerificationVersion?,
        memo: String,
        type: DelegatedCustodyTransactionType
    ) {
        self.account = account
        self.amount = amount
        self.currency = currency
        self.destination = destination
        self.fee = fee
        self.feeCurrency = feeCurrency
        self.maxVerificationVersion = maxVerificationVersion
        self.memo = memo
        self.type = type
    }
}

public enum DelegatedCustodyFee: Hashable {
    case low
    case normal
    case high
    case custom(String)
}

public enum DelegatedCustodyAmount: Hashable {
    case max
    case custom(String)
}

public enum DelegatedCustodyTransactionType: Hashable {
    case payment
    case swap(data: String, gasLimit: String, value: String)
    case tokenApproval(spender: String)

    public var type: String {
        switch self {
        case .payment:
            return "PAYMENT"
        case .swap:
            return "SWAP"
        case .tokenApproval:
            return "TOKEN_APPROVAL"
        }
    }

    public var spender: String? {
        switch self {
        case .payment:
            return nil
        case .swap:
            return nil
        case .tokenApproval(let value):
            return value
        }
    }
}
