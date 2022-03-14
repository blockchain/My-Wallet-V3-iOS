// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxRelay
import RxSwift
import ToolKit
import WalletPayloadKit

// TODO: Handle `CryptoValue`
/// The calculation state of Simple Buy suggested fiat amounts to buy
public typealias SuggestedAmountsCalculationState = ValueCalculationState<[FiatValue]>

/// A simple buy suggested amounts API
public protocol SuggestedAmountsServiceAPI: AnyObject {

    /// Streams the suggested amounts
    var calculationState: Observable<SuggestedAmountsCalculationState> { get }

    /// Refresh, triggering a re-fetch of `SuggestedAmountsCalculationState`.
    /// Makes `calculationState` to stream an updated value
    func refresh()
}

final class SuggestedAmountsService: SuggestedAmountsServiceAPI {

    // MARK: - Exposed

    var calculationState: Observable<SuggestedAmountsCalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    // MARK: - Injected

    private let client: SuggestedAmountsClientAPI

    // MARK: - Accessors

    private var calculationStateRelay = BehaviorRelay<SuggestedAmountsCalculationState>(value: .invalid(.empty))
    private let fetchTriggerRelay: PublishRelay<Void>
    private let reactiveWallet: ReactiveWalletAPI
    private let fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    private lazy var setup: Void = Observable
        .combineLatest(
            fiatCurrencySettingsService.displayCurrencyPublisher.asObservable(),
            fetchTriggerRelay.asObservable(),
            reactiveWallet.waitUntilInitialized
        )
        .map(\.0)
        .flatMapLatest(weak: self) { (self, currency) -> Observable<[FiatValue]> in
            self.fetchSuggestedAmounts(for: currency).asObservable()
        }
        .map { SuggestedAmountsCalculationState.value($0) }
        .catchAndReturn(.invalid(.valueCouldNotBeCalculated))
        .bindAndCatch(to: calculationStateRelay)
        .disposed(by: disposeBag)

    // MARK: - Setup

    init(
        client: SuggestedAmountsClientAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI = resolve()
    ) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        fetchTriggerRelay = PublishRelay<Void>()
    }

    /// Refreshes the cached data set
    func refresh() {
        fetchTriggerRelay.accept(())
    }

    private func fetchSuggestedAmounts(for currency: FiatCurrency) -> Single<[FiatValue]> {
        client.suggestedAmounts(for: currency)
            .map { SuggestedAmounts(response: $0) }
            .map { $0[currency] }
            .asSingle()
    }
}
