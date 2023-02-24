// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import PlatformKit

/// This is for transferring or sending custodial funds to
/// a non-custodial wallet
protocol CustodialTransferClientAPI {

    /// A `403` means an internal send is pending.
    /// A `409` means you have insufficient funds for the internal send.
    func send(
        transferRequest: CustodialTransferRequest
    ) -> AnyPublisher<CustodialTransferResponse, NabuNetworkError>

    func custodialTransferFeesForProduct(_ product: Product) -> AnyPublisher<CustodialTransferFeesResponse, NabuNetworkError>

    func custodialTransferFees() -> AnyPublisher<CustodialTransferFeesResponse, NabuNetworkError>

    func custodialWithdrawalFees(
        currency: String,
        fiatCurrency: String,
        amount: String,
        max: Bool
    ) -> AnyPublisher<WithdrawalFeesResponse, NabuNetworkError>
}
