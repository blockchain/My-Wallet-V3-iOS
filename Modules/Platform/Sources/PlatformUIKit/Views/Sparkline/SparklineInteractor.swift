// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

public class SparklineInteractor: SparklineInteracting {

    // MARK: - SparklineInteracting

    public let cryptoCurrency: CryptoCurrency

    public var calculationState: Observable<SparklineCalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    private lazy var setup: Void = priceService.calculationState
        .map { state -> SparklineCalculationState in
            switch state {
            case .calculating, .invalid:
                return .calculating
            case .value(let value):
                let prices = value.historicalPrices.prices.map(\.moneyValue.displayMajorValue)
                return .value(prices)
            }
        }
        .catchAndReturn(.calculating)
        .bindAndCatch(to: calculationStateRelay)
        .disposed(by: disposeBag)

    private let priceService: HistoricalFiatPriceServiceAPI
    private let calculationStateRelay = BehaviorRelay<SparklineCalculationState>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()

    public init(priceService: HistoricalFiatPriceServiceAPI, cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
        self.priceService = priceService
    }
}
