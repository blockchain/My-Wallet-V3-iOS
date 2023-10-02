// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

protocol BankTransferClientAPI {

    func startBankTransfer(
        id: String,
        amount: MoneyValue,
        product: String
    ) -> AnyPublisher<BankTranferPaymentResponse, NabuNetworkError>

    func createWithdrawOrder(
        id: String,
        amount: MoneyValue,
        product: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}
