//
//  SwapActivityItemEventFetcherAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol SwapActivityItemEventFetcherAPI {
    func fetchSwapActivityEvents(date: Date, fiatCurrency: String) -> Single<PageResult<SwapActivityItemEvent>>
}

public final class SwapActivityItemEventsService: SwapActivityItemEventFetcherAPI {

    // MARK: Private Properties

    private let currency: CryptoCurrency
    private let service: SwapActivityServiceAPI

    // MARK: Init

    public init(currency: CryptoCurrency, service: SwapActivityServiceAPI) {
        self.currency = currency
        self.service = service
    }

    // MARK: SwapActivityItemEventFetcherAPI

    public func fetchSwapActivityEvents(date: Date, fiatCurrency: String) -> Single<PageResult<SwapActivityItemEvent>> {
        service
            .fetchActivity(
                from: date,
                cryptoCurrency: currency
            )
            .map(weak: self) { (self, events) -> PageResult<SwapActivityItemEvent> in
                PageResult(
                    hasNextPage: events.count == self.service.pageSize,
                    items: events
                )
            }
    }
}
