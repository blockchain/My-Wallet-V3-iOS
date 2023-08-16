// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class BankTransferRepository: BankTransferRepositoryAPI {

    // MARK: - Properties

    private let app: AppProtocol
    private let client: BankTransferClientAPI

    // MARK: - Setup

    init(app: AppProtocol = resolve(), client: BankTransferClientAPI = resolve()) {
        self.app = app
        self.client = client
    }

    // MARK: - BankTransferRepositoryAPI

    func startBankTransfer(
        id: String,
        amount: MoneyValue
    ) -> AnyPublisher<BankTranferPayment, NabuNetworkError> {
        app.publisher(for: blockchain.api.nabu.gateway.user.products.product[useExternalTradingAccount].is.eligible, as: Bool.self)
            .replaceError(with: false)
            .flatMap { [client] isEligible in
                client.startBankTransfer(id: id, amount: amount, product: isEligible ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
                    .map(BankTranferPayment.init)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

    }
}
