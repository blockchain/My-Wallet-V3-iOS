// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit

public protocol BuySellActivityItemEventServiceAPI: AnyObject {
    func buySellActivityEvents(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[BuySellActivityItemEvent], OrdersServiceError>
}

final class BuySellActivityItemEventService: BuySellActivityItemEventServiceAPI {

    private let ordersService: OrdersServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private var isVerifiedApproved: AnyPublisher<Bool, Never> {
        kycTiersService
            .tiers
            .map(\.isVerifiedApproved)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    init(
        ordersService: OrdersServiceAPI,
        kycTiersService: KYCTiersServiceAPI
    ) {
        self.ordersService = ordersService
        self.kycTiersService = kycTiersService
    }

    func buySellActivityEvents(cryptoCurrency: CryptoCurrency) -> AnyPublisher<[BuySellActivityItemEvent], OrdersServiceError> {
        isVerifiedApproved
            .setFailureType(to: OrdersServiceError.self)
            .flatMap { [ordersService] isVerifiedApproved -> AnyPublisher<[BuySellActivityItemEvent], OrdersServiceError> in
                guard isVerifiedApproved else {
                    return .just([])
                }
                return ordersService.orders
                    .map { orders -> [BuySellActivityItemEvent] in
                        orders
                            .filter { order in
                                order.outputValue.currency == cryptoCurrency
                                || order.inputValue.currency == cryptoCurrency
                            }
                            .map(BuySellActivityItemEvent.init(with:))
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
