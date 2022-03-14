// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

public final class AccountAssetBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    enum Source {
        case account(BlockchainAccount)
        case asset(CryptoAsset)
    }

    // MARK: - Exposed Properties

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let refreshRelay = BehaviorRelay<Void>(value: ())
    private let account: Source

    // MARK: - Setup

    private func balancePair(fiatCurrency: FiatCurrency) -> AnyPublisher<MoneyValuePair, Error> {
        switch account {
        case .account(let account):
            return account.balancePair(fiatCurrency: fiatCurrency)
        case .asset(let cryptoAsset):
            return cryptoAsset
                .accountGroup(filter: .all)
                .flatMap { accountGroup in
                    accountGroup.balancePair(fiatCurrency: fiatCurrency)
                }
                .eraseToAnyPublisher()
        }
    }

    private lazy var setup: Void = Observable
        .combineLatest(
            fiatCurrencyService.displayCurrencyPublisher.asObservable(),
            refreshRelay.asObservable()
        )
        .map(\.0)
        .flatMapLatest(weak: self) { (self, fiatCurrency) -> Observable<MoneyValuePair> in
            self.balancePair(fiatCurrency: fiatCurrency).asObservable()
        }
        .map { moneyValuePair -> InteractionState in
            InteractionState.loaded(
                next: AssetBalanceViewModel.Value.Interaction(
                    primaryValue: moneyValuePair.base,
                    secondaryValue: moneyValuePair.quote,
                    pendingValue: nil
                )
            )
        }
        .subscribe(onNext: { [weak self] state in
            self?.stateRelay.accept(state)
        })
        .disposed(by: disposeBag)

    public init(
        account: BlockchainAccount,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.account = .account(account)
        self.fiatCurrencyService = fiatCurrencyService
    }

    public init(
        cryptoAsset: CryptoAsset,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        account = .asset(cryptoAsset)
        self.fiatCurrencyService = fiatCurrencyService
    }

    public func refresh() {
        refreshRelay.accept(())
    }
}
