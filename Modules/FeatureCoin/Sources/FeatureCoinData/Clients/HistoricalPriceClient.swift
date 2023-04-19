// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

public protocol HistoricalPriceClientAPI {

    func fetchPriceIndexes(
        baseCode: String,
        quoteCode: String,
        window: Interval,
        scale: TimeInterval,
        relativeTo date: Date
    ) -> AnyPublisher<[PriceIndex], NetworkError>
}

public struct HistoricalPriceClient: HistoricalPriceClientAPI {

    private let request: RequestBuilder
    private let network: NetworkAdapterAPI
    private let calendar: Calendar

    private let maxAge: TimeInterval = 1238992000

    public init(
        request: RequestBuilder,
        network: NetworkAdapterAPI,
        calendar: Calendar = .current
    ) {
        self.request = request
        self.network = network
        self.calendar = calendar
    }

    public func fetchPriceIndexes(
        baseCode: String,
        quoteCode: String,
        window: Interval,
        scale: TimeInterval,
        relativeTo date: Date
    ) -> AnyPublisher<[PriceIndex], NetworkError> {

        let startingAt = calendar.date(
            byAdding: window.component,
            value: -window.value,
            to: date
        )!

        let start = startingAt.timeIntervalSince1970
            .clamped(to: maxAge...)

        let request = request.get(
            path: "/price/index-series",
            parameters: [
                URLQueryItem(name: "base", value: baseCode),
                URLQueryItem(name: "quote", value: quoteCode),
                URLQueryItem(name: "start", value: Int(start - (scale * 2)).description),
                URLQueryItem(name: "end", value: Int(date.timeIntervalSince1970).description),
                URLQueryItem(name: "scale", value: Int(scale).description)
            ]
        )!

        return network.perform(request: request, responseType: [PriceIndex].self)
    }
}
