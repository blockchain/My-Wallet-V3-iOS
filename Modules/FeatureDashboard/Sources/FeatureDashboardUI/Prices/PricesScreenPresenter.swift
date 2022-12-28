// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class PricesScreenPresenter {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Dashboard.Prices

    // MARK: - Internal Properties

    /// Should be triggered when user pulls-to-refresh.
    let refreshRelay = BehaviorRelay<Void>(value: ())
    let searchRelay = BehaviorRelay<String>(value: "")
    private(set) lazy var router: PortfolioRouter = .init()
    var sections: Observable<[PricesViewModel]> {
        sectionsRelay.asObservable()
    }

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let drawerRouter: DrawerRouting
    private let interactor: PricesScreenInteractor
    private let reloadRelay: PublishRelay<Void> = .init()
    private let sectionsRelay: BehaviorRelay<[PricesViewModel]> = .init(value: [])

    // MARK: - Init

    init(
        drawerRouter: DrawerRouting = resolve(),
        interactor: PricesScreenInteractor
    ) {
        self.drawerRouter = drawerRouter
        self.interactor = interactor
    }

    // MARK: - Setup

    /// Should be called once the view is loaded
    func setup() {
        let searchText = reloadRelay
            .startWith(())
            .throttle(.seconds(250), scheduler: MainScheduler.asyncInstance)
            .flatMapLatest { [searchRelay] in
                searchRelay.asObservable()
            }
        Observable.combineLatest(interactor.cryptoCurrencies.asObservable(), searchText)
            .map { cryptoCurrencies, searchText -> [CryptoCurrency] in
                guard !searchText.isEmpty else {
                    return cryptoCurrencies
                }
                return cryptoCurrencies.filter { cryptoCurrency in
                    cryptoCurrency.matchSearch(searchText)
                }
            }
            .map { [interactor] filteredCurrencies -> [PricesCellType] in
                guard !filteredCurrencies.isEmpty else {
                    let labelContent = LabelContent(
                        text: LocalizedString.noResults,
                        font: .main(.medium, 16),
                        color: .darkTitleText,
                        alignment: .center
                    )
                    return [.emptyState(labelContent)]
                }
                return filteredCurrencies
                    .compactMap { cryptoCurrency in
                        let presenter: () -> PricesTableViewCellPresenter = {
                            PricesTableViewCellPresenter(
                                cryptoCurrency: cryptoCurrency,
                                interactor: interactor.assetPriceViewInteractor(for: cryptoCurrency)
                            )
                        }
                        return .currency(cryptoCurrency, presenter)
                    }
            }
            .map(PricesViewModel.init)
            .map { [$0] }
            .bind(to: sectionsRelay)
            .disposed(by: disposeBag)

        refreshRelay
            .throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] _ in
                self?.interactor.refresh()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    /// Should be invoked upon tapping navigation bar leading button
    func navigationBarLeadingButtonPressed() {
        drawerRouter.toggleSideMenu()
    }
}
