// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

public final class AccountAssetBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    // MARK: - Exposed Properties

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let refreshRelay = BehaviorRelay<Void>(value: ())
    private let account: BlockchainAccount
    private let app: AppProtocol

    public init(
        account: BlockchainAccount,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.account = account
        self.fiatCurrencyService = fiatCurrencyService
        self.app = app
    }

    // MARK: - Setup

    private var model: AnyPublisher<InteractionState, Never> {
        fiatCurrencyService.displayCurrencyPublisher
            .flatMap { [account] fiatCurrency -> AnyPublisher<(balance: MoneyValue?, quote: MoneyValue?), Never> in
                account.safeBalancePair(fiatCurrency: fiatCurrency)
            }
            .map { balance, quote -> AssetBalanceViewModel.Value.Interaction in
                AssetBalanceViewModel.Value.Interaction(
                    primaryValue: quote,
                    secondaryValue: balance
                )
            }
            .map(InteractionState.loaded(next:))
            .eraseToAnyPublisher()
    }

    private lazy var setup: Void = refreshRelay.asObservable()
        .flatMapLatest(weak: self) { (self, _) -> Observable<InteractionState> in
            self.model.asObservable()
        }
        .subscribe(
            onNext: { [weak self] state in
                self?.stateRelay.accept(state)
            }
        )
        .disposed(by: disposeBag)

    public func refresh() {
        refreshRelay.accept(())
    }
}
