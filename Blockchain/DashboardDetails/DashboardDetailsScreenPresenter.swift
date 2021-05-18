//
//  DashboardDetailsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

/// This enum aggregates possible action types that can be done in the dashboard
enum DashboadDetailsAction {
    case trading(CryptoCurrency)
    case savings(CryptoCurrency)
    case nonCustodial(CryptoCurrency)
}

final class DashboardDetailsScreenPresenter {
    
    private typealias AccessilbityId = Accessibility.Identifier.DashboardDetails
    private typealias LocalizedString = LocalizationConstants.DashboardDetails.BalanceCell
    
    enum BalancePresentationState {
        case visible(CurrentBalanceCellPresenter)
        
        // TODO: Currently not handled
        case hidden
                
        var presenter: CurrentBalanceCellPresenter? {
            switch self {
            case .visible(let presenter):
                return presenter
            case .hidden:
                return nil
            }
        }
        
        var isVisible: Bool {
            switch self {
            case .visible:
                return true
            case .hidden:
                return false
            }
        }
    }
    
    enum PresentationAction {
        case show(BalanceType)
    }

    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        .close
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: currency.name)
    }
    
    var barStyle: Screen.Style.Bar {
        .lightContent()
    }
    
    // MARK: - Types
    
    enum CellType: Hashable {
        case balance(BalanceType)
        case priceAlert
        case chart
    }
    
    // MARK: - Rx
    
    var isScrollEnabled: Driver<Bool> {
        scrollingEnabledRelay.asDriver()
    }
    
    var presentationAction: Signal<PresentationAction> {
        presentationActionRelay.asSignal()
    }
        
    // MARK: - Exposed Properties
    
    var walletBalancePresenter: CurrentBalanceCellPresenter? {
        walletBalanceStateRelay.value.presenter
    }
    
    var tradingBalancePresenter: CurrentBalanceCellPresenter? {
        tradingBalanceStateRelay.value.presenter
    }
    
    var savingsBalancePresenter: CurrentBalanceCellPresenter? {
        savingsBalanceStateRelay.value.presenter
    }
    
    /// The dashboard action
    var action: Signal<DashboadDetailsAction> {
        actionRelay.asSignal()
    }
    
    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }
    
    /// Returns the ordered cell types
    var cellArrangement: [CellType] {
        var cellTypes: [CellType] = []
        cellTypes.append(.priceAlert)
        cellTypes.append(.chart)
        if shouldShowNonCustodialBalance {
            cellTypes.append(.balance(.nonCustodial))
        }
        if shouldShowTradingBalance {
            cellTypes.append(.balance(.custodial(.trading)))
        }
        if shouldShowSavingsBalance {
            cellTypes.append(.balance(.custodial(.savings)))
        }
        return cellTypes
    }

    var indexByCellType: [CellType: Int] {
        var indexByCellType: [CellType: Int] = [:]
        for (index, cellType) in cellArrangement.enumerated() {
            indexByCellType[cellType] = index
        }
        return indexByCellType
    }
    
    // MARK: - Public Properties (Presenters)
    
    let lineChartCellPresenter: AssetLineChartTableViewCellPresenter

    let currency: CryptoCurrency
    
    /// Selection relay for a single presenter
    let presenterSelectionRelay = PublishRelay<CellType>()
    
    // MARK: - Private Properties

    private var shouldShowNonCustodialBalance: Bool {
        walletBalancePresenter != nil
    }

    private var shouldShowTradingBalance: Bool {
        tradingBalancePresenter != nil
    }

    private var shouldShowSavingsBalance: Bool {
        savingsBalancePresenter != nil
    }

    private let presentationActionRelay = PublishRelay<PresentationAction>()
    private let walletBalanceStateRelay = BehaviorRelay<BalancePresentationState>(value: .hidden)
    private let tradingBalanceStateRelay = BehaviorRelay<BalancePresentationState>(value: .hidden)
    private let savingsBalanceStateRelay = BehaviorRelay<BalancePresentationState>(value: .hidden)
    
    private unowned let router: DashboardRouter
    private let interactor: DashboardDetailsScreenInteractor
    private let actionRelay = PublishRelay<DashboadDetailsAction>()
    private let scrollingEnabledRelay = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(using interactor: DashboardDetailsScreenInteractor,
         with currency: CryptoCurrency,
         fiatCurrency: FiatCurrency,
         router: DashboardRouter) {
        self.router = router
        self.currency = currency
        self.interactor = interactor
        
        lineChartCellPresenter = AssetLineChartTableViewCellPresenter(
            cryptoCurrency: currency,
            fiatCurrency: fiatCurrency,
            historicalFiatPriceService: interactor.priceServiceAPI
        )
        
        lineChartCellPresenter.isScrollEnabled
            .drive(scrollingEnabledRelay)
            .disposed(by: disposeBag)
        
        presenterSelectionRelay
            .compactMap { cellType -> BalanceType? in
                guard case let .balance(balanceType) = cellType else { return nil }
                return balanceType
            }
            .map { balanceType in
                switch balanceType {
                case .nonCustodial:
                    return .nonCustodial(currency)
                case .custodial(.trading):
                    return .trading(currency)
                case .custodial(.savings):
                    return .savings(currency)
                }
            }
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should be called on `viewDidLoad`
    func setup() {
        setupWalletBalancePresenter()
        setupTradingBalancePresenter()
        setupSavingsBalancePresenter()
        
        interactor.refresh()
    }
    
    private func setupWalletBalancePresenter() {
        interactor.nonCustodialActivitySupported
            .filter { $0 }
            .take(1) // This to ensure the cell shows only once
            .map(weak: self) { (self, exists) in
                guard exists else { return .hidden }
                return .visible(
                    self.balanceCellPresenter(for: .nonCustodial)
                )
            }
            .bindAndCatch(to: walletBalanceStateRelay)
            .disposed(by: disposeBag)

        walletBalanceStateRelay
            .filter { $0.isVisible }
            .mapToVoid()
            .map { .show(.nonCustodial) }
            .bindAndCatch(to: presentationActionRelay)
            .disposed(by: disposeBag)
    }
        
    private func setupSavingsBalancePresenter() {
        interactor.custodialSavingsFunded
            .filter { $0 }
            .take(1) // This to ensure the cell shows only once
            .map(weak: self) { (self, exists) in
                guard exists else { return .hidden }
                return .visible(
                    self.balanceCellPresenter(for: .custodial(.savings))
                )
            }
            .bindAndCatch(to: savingsBalanceStateRelay)
            .disposed(by: disposeBag)
        
        savingsBalanceStateRelay
            .filter { $0.isVisible }
            .mapToVoid()
            .map { .show(.custodial(.savings)) }
            .bindAndCatch(to: presentationActionRelay)
            .disposed(by: disposeBag)
    }
    
    private func setupTradingBalancePresenter() {
        Observable.just(
            .visible(self.balanceCellPresenter(for: .custodial(.trading)))
            )
            .bindAndCatch(to: tradingBalanceStateRelay)
            .disposed(by: disposeBag)
        
        tradingBalanceStateRelay
            .filter { $0.isVisible }
            .mapToVoid()
            .map { .show(.custodial(.trading)) }
            .bindAndCatch(to: presentationActionRelay)
            .disposed(by: disposeBag)
    }
    
    private func balanceCellPresenter(for accountType: SingleAccountType) -> CurrentBalanceCellPresenter {
        
        let descriptionValue: () -> Observable<String> = { [weak self] in
            guard let self = self else { return .empty() }
            switch accountType {
            case .nonCustodial:
                return .just(LocalizedString.Description.nonCustodial)
            case .custodial(.savings):
                return self.interactor
                    .rate
                    .asObservable()
                    .compactMap { $0 }
                    .map { "\(LocalizedString.Description.savingsPrefix) \($0)\(LocalizedString.Description.savingsSuffix)" }
            case .custodial(.trading):
                return .just(LocalizedString.Description.trading)
            }
        }
    
        return CurrentBalanceCellPresenter(
            interactor: CurrentBalanceCellInteractor(
                balanceFetching: interactor.balanceFetcher,
                accountType: accountType
            ),
            descriptionValue: descriptionValue,
            currency: .crypto(currency),
            titleAccessibilitySuffix: "\(AccessilbityId.CurrentBalanceCell.titleValue)",
            descriptionAccessibilitySuffix: "\(AccessilbityId.CurrentBalanceCell.descriptionValue)",
            pendingAccessibilitySuffix: "\(AccessilbityId.CurrentBalanceCell.pendingValue)",
            descriptors: .default(
                cryptoAccessiblitySuffix: "\(AccessilbityId.CurrentBalanceCell.cryptoValue).\(currency.code)",
                fiatAccessiblitySuffix: "\(AccessilbityId.CurrentBalanceCell.fiatValue).\(currency.code)")
        )
    }
}
