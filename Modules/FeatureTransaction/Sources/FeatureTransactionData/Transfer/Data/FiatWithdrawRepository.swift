// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class FiatWithdrawRepository: FiatWithdrawRepositoryAPI {

    // MARK: - Properties

    private let app: AppProtocol
    private let client: BankTransferClientAPI

    // MARK: - Setup

    init(app: AppProtocol = resolve(), client: BankTransferClientAPI = resolve()) {
        self.app = app
        self.client = client
    }

    // MARK: - BankTransferServiceAPI

    func createWithdrawOrder(
        id: String,
        amount: MoneyValue
    ) -> AnyPublisher<Void, NabuNetworkError> {
        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self)
            .replaceError(with: false)
            .flatMap { [client] isEligible in
                client.createWithdrawOrder(id: id, amount: amount, product: isEligible ? "EXTERNAL_BROKERAGE" : "SIMPLEBUY")
            }
            .eraseToAnyPublisher()
    }
}
