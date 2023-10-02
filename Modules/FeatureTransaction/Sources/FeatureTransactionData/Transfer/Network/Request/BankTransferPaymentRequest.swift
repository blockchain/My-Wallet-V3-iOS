// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BankTransferPaymentRequest: Encodable {
    struct BankTransferPaymentAttributes: Encodable {
        let callback: String?
    }

    var amountMinor: String
    var currency: String
    var product: String = "SIMPLEBUY"
    var attributes: BankTransferPaymentAttributes?
}
