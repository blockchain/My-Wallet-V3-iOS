// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class FiatBalanceCollectionViewInteractor {

    // MARK: - Types

    typealias State = ValueCalculationState<[FiatCustodialBalanceViewInteractor]>

    // MARK: - Exposed Properties

    /// Streams the interactors
    var interactorsState: Observable<State> {
        _ = setup
        return interactorsStateRelay.asObservable()
    }

    var interactors: Observable<[FiatCustodialBalanceViewInteractor]> {
        interactorsState
            .compactMap(\.value)
            .startWith([])
    }

    // MARK: - Injected Properties

    private let app: AppProtocol
    private let tiersService: KYCTiersServiceAPI
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let userService: NabuUserServiceAPI
    private let refreshRelay = PublishRelay<Void>()
    private let coincore: CoincoreAPI
    private let disposeBag = DisposeBag()

    // MARK: - Accessors

    let interactorsStateRelay = BehaviorRelay<State>(value: .invalid(.empty))

    private func fiatAccounts() -> Single<[SingleAccount]> {
        tiersService.tiers
            .map(\.isVerifiedApproved)
            .replaceError(with: false)
            .asSingle()
            .flatMap(weak: self) { (self, isVerifiedApproved) in
                guard isVerifiedApproved else {
                    return .just([])
                }
                return self.coincore
                    .fiatAsset
                    .accountGroup(filter: .allExcludingExchange)
                    .compactMap { $0 }
                    .map(\.accounts)
                    .asObservable()
                    .asSingle()
            }
    }

    private lazy var setup: Void = Observable
        .combineLatest(
            fiatCurrencyService.displayCurrencyPublisher.asObservable(),
            refreshRelay.asObservable(),
            app.publisher(for: blockchain.user.currency.currencies, as: [FiatCurrency].self)
                .compactMap(\.value)
                .asObservable()
        ) { (fiatCurrency: $0, _: $1, currencies: $2) }
        .flatMapLatest(weak: self) { (self, data) in
            self.fiatAccounts()
                .asObservable()
                .map { accounts in
                    data.currencies
                        .compactMap { currency in
                            accounts.first(where: { account in account.currencyType.fiatCurrency == currency })
                        }
                        .map(FiatCustodialBalanceViewInteractor.init(account:))
                }
        }
        .map { .value($0) }
        .startWith(.calculating)
        .catchAndReturn(.invalid(.empty))
        .bindAndCatch(to: interactorsStateRelay)
        .disposed(by: disposeBag)

    init(
        app: AppProtocol = resolve(),
        tiersService: KYCTiersServiceAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        userService: NabuUserServiceAPI = resolve()
    ) {
        self.app = app
        self.coincore = coincore
        self.tiersService = tiersService
        self.paymentMethodsService = paymentMethodsService
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.userService = userService
    }

    func refresh() {
        refreshRelay.accept(())
    }
}

extension FiatBalanceCollectionViewInteractor: Equatable {
    static func == (lhs: FiatBalanceCollectionViewInteractor, rhs: FiatBalanceCollectionViewInteractor) -> Bool {
        lhs.interactorsStateRelay.value == rhs.interactorsStateRelay.value
    }
}

extension FiatBalanceCollectionViewInteractor {
    var hasBalances: Observable<Bool> {
        interactorsState
            .compactMap(\.value)
            .map(\.isNotEmpty)
            .catchAndReturn(false)
    }

    public var isInTradingMode: Observable<Bool> {
        app
            .modePublisher()
            .asObservable()
            .map { $0 != .pkw }
            .catchAndReturn(false)
    }

    func reloadBalances() {
        refresh()
    }
}
