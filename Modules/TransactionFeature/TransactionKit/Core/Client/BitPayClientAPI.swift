// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

protocol BitPayClientAPI {
    /// 1. First we build the BitPay model using the `payment-request` endpoint, passing up an invoice identifier
    /// and a currency type.
    func bitpayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<BitpayPaymentRequest>
    /// 2. Verify the payment request
    func verifySignedTransaction(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Completable
    /// 3. Post the payment with an `invoiceID`, the currency, and the transactionHex (not to be confused with the transaction hash)
    func postPayment(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo>
}
