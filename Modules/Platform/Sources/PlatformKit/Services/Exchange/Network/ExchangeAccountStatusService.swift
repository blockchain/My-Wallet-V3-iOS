// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import RxSwift
import ToolKit

public enum ExchangeAccountStatusServiceError: Error {
    case unknown(Error)
    case network(NabuNetworkError)
}

public protocol ExchangeAccountStatusServiceAPI {

    var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountStatusServiceError> { get }

    var hasEnabled2FA: AnyPublisher<Bool, NabuNetworkError> { get }
}

public final class ExchangeAccountStatusService: ExchangeAccountStatusServiceAPI {

    // MARK: - ExchangeLinkStatusServiceAPI

    public var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountStatusServiceError> {
        nabuUserService.user
            .mapError(ExchangeAccountStatusServiceError.unknown)
            .map(\.hasLinkedExchangeAccount)
            .eraseToAnyPublisher()
    }

    public var hasEnabled2FA: AnyPublisher<Bool, NabuNetworkError> {
        // It does not matter what asset we fetch.
        client.exchangeAddress(with: .bitcoin)
            // If the user has accounts returned,
            // then they have 2FA enabled.
            .map { _ in true }
            // If an error is thrown when fetching accounts
            // parse the error to determine if it is because 2FA is
            // not enabled.
            .catch { error -> AnyPublisher<Bool, NabuNetworkError> in
                if error.code == .bad2fa {
                    .just(false)
                } else {
                    .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let nabuUserService: NabuUserServiceAPI
    private let client: ExchangeAccountsProviderClientAPI

    // MARK: - Init

    init(
        nabuUserService: NabuUserServiceAPI = resolve(),
        client: ExchangeAccountsClientAPI = resolve()
    ) {
        self.nabuUserService = nabuUserService
        self.client = client
    }
}
