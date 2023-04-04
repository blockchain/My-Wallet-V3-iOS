// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class DashboardFiatBalancesPresenter {

    // MARK: - Exposed Properties

    var tap: Driver<DashboardItemDisplayAction<CurrencyType>> {
        selectionRelay
            .asDriver()
    }

    /// Streams only distinct actions
    var action: Driver<DashboardItemDisplayAction<FiatBalanceCollectionViewPresenter>> {
        _ = setup
        return actionRelay
            .asDriver()
            .distinctUntilChanged()
    }

    // MARK: - Private Properties

    private let selectionRelay = BehaviorRelay<DashboardItemDisplayAction<CurrencyType>>(value: .hide)
    private let actionRelay = BehaviorRelay<DashboardItemDisplayAction<FiatBalanceCollectionViewPresenter>>(
        value: .hide
    )

    private let presenter: FiatBalanceCollectionViewPresenter
    private let interactor: FiatBalanceCollectionViewInteractor
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        let presenter = self.presenter
        return Observable
            .combineLatest(
                interactor.hasBalances,
                interactor.isInTradingMode
            )
            .map { $0 && $1 ? .show(presenter) : .hide }
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Setup

    init(
        interactor: FiatBalanceCollectionViewInteractor
    ) {
        self.interactor = interactor
        self.presenter = FiatBalanceCollectionViewPresenter(interactor: interactor)

        presenter
            .tap
            .emit(onNext: { [weak self] currencyType in
                guard let self else { return }
                selectionRelay.accept(.show(currencyType))
            })
            .disposed(by: disposeBag)
    }

    func refresh() {
        interactor.refresh()
    }
}
