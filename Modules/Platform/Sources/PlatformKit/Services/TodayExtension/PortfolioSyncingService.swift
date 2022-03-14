// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift

final class PortfolioSyncingService: BalanceSharingSettingsServiceAPI {

    // MARK: - Setup

    private lazy var setup: Void = balanceSyncRelay
        .flatMap(weak: self) { (self, _) -> Observable<Bool> in
            self.isEnabled
        }
        .flatMap(weak: self) { (self, value) -> Observable<Portfolio?> in
            guard value else { return .just(nil) }
            return self.portfolioProviding
                .portfolio
                .optional()
        }
        .catchAndReturn(nil)
        .bindAndCatch(to: container.portfolioRelay)
        .disposed(by: disposeBag)

    // MARK: - Private Properties

    private let balanceSyncRelay = PublishRelay<Void>()
    private let container: SharedContainerUserDefaults
    private let portfolioProviding: PortfolioProviding
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        sharedContainerUserDefaults: SharedContainerUserDefaults = SharedContainerUserDefaults.default,
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        portfolioProviding = PortfolioProvider(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService
        )
        container = sharedContainerUserDefaults
    }

    // MARK: - BalanceSharingSettingsServiceAPI

    var isEnabled: Observable<Bool> {
        container
            .portfolioSyncEnabled
            .distinctUntilChanged()
    }

    func sync() {
        _ = setup
        balanceSyncRelay.accept(())
    }

    func balanceSharing(enabled: Bool) -> Completable {
        Completable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }
            self.container.shouldSyncPortfolio = enabled
            observer(.completed)
            return Disposables.create()
        }
    }
}
