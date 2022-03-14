// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

/// Implementation of `AssetPriceViewInteracting` that streams a State for the daily asset price/change.
public final class AssetPriceViewDailyInteractor: AssetPriceViewInteracting {

    public var state: Observable<DashboardAsset.State.AssetPrice.Interaction> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private lazy var setup: Void = Observable
        .combineLatest(
            fiatCurrencyService.displayCurrencyPublisher.asObservable(),
            refreshRelay.startWith(())
        )
        .map(\.0)
        .flatMapLatest(weak: self) { (self, fiatCurrency) in
            self.fetch(fiatCurrency: fiatCurrency).asObservable()
        }
        .map(DashboardAsset.State.AssetPrice.Interaction.loaded)
        .catchAndReturn(.loading)
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let cryptoCurrency: CryptoCurrency
    private let priceService: PriceServiceAPI
    private let stateRelay = BehaviorRelay<DashboardAsset.State.AssetPrice.Interaction>(value: .loading)
    private let disposeBag = DisposeBag()
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let refreshRelay = PublishRelay<Void>()

    // MARK: - Setup

    public init(
        cryptoCurrency: CryptoCurrency,
        priceService: PriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
    }

    // MARK: - Public Functions

    public func refresh() {
        refreshRelay.accept(())
    }

    private func fetch(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<DashboardAsset.Value.Interaction.AssetPrice, Error> {
        priceService.price(of: cryptoCurrency, in: fiatCurrency)
            .combineLatest(
                priceService.price(of: cryptoCurrency, in: fiatCurrency, at: .oneDay)
                    .optional()
                    .replaceError(with: nil)
                    .mapError(to: PriceServiceError.self)
            )
            .tryMap { currentPrice, previousPrice -> DashboardAsset.Value.Interaction.AssetPrice in
                let historicalPrice = previousPrice
                    .flatMap { previousPrice in
                        DashboardAsset.Value.Interaction.AssetPrice.HistoricalPrice(
                            time: .days(1),
                            currentPrice: currentPrice.moneyValue,
                            previousPrice: previousPrice.moneyValue
                        )
                    }
                return DashboardAsset.Value.Interaction.AssetPrice(
                    currentPrice: currentPrice.moneyValue,
                    historicalPrice: historicalPrice
                )
            }
            .eraseToAnyPublisher()
    }
}
