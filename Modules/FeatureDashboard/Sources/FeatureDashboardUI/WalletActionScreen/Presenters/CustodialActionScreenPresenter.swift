// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CustodialActionScreenPresenter: WalletActionScreenPresenting {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.WalletActionSheet
    typealias CellType = WalletActionCellType

    // MARK: - Properties

    var sections: Observable<[WalletActionItemsSectionViewModel]> {
        sectionsRelay
            .asObservable()
    }

    let assetBalanceViewPresenter: CurrentBalanceCellPresenter

    var currency: CurrencyType {
        interactor.currency
    }

    let selectionRelay: PublishRelay<WalletActionCellType> = .init()

    // MARK: - Private Properties

    private var actionCellPresenters: Single<[WalletActionCellPresenter]> {
        interactor
            .availableActions
            .map { actions in
                actions.compactMap(\.walletAction)
            }
            .map { $0.sorted() }
            .map { [currency] actions in
                actions.map {
                    WalletActionCellPresenter(
                        currencyType: currency,
                        action: $0
                    )
                }
            }
    }

    private let sectionsRelay = BehaviorRelay<[WalletActionItemsSectionViewModel]>(value: [])
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let eligiblePaymentService: PaymentMethodsServiceAPI
    private let interactor: WalletActionScreenInteracting
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        using interactor: WalletActionScreenInteracting,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        stateService: CustodyActionStateServiceAPI,
        eligiblePaymentService: PaymentMethodsServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.interactor = interactor
        self.enabledCurrenciesService = enabledCurrenciesService
        self.eligiblePaymentService = eligiblePaymentService
        self.analyticsRecorder = analyticsRecorder

        let currency = interactor.currency
        let descriptionValue: () -> Observable<String> = {
            switch currency {
            case .crypto(let cryptoCurrency):
                return .just(cryptoCurrency.name)
            case .fiat(let fiatCurrency):
                return .just(fiatCurrency.displayCode)
            }
        }

        self.assetBalanceViewPresenter = CurrentBalanceCellPresenter(
            interactor: interactor.balanceCellInteractor,
            descriptionValue: descriptionValue,
            currency: interactor.currency,
            viewAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.view)",
            titleAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.title)",
            descriptionAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.description)",
            pendingAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.pending)",
            descriptors: .default(
                cryptoAccessiblitySuffix: "\(AccessibilityId.CustodialAction.cryptoValue)",
                fiatAccessiblitySuffix: "\(AccessibilityId.CustodialAction.fiatValue)"
            )
        )

        actionCellPresenters
            .catch { _ in
                .just([])
            }
            .map { [assetBalanceViewPresenter] presenters -> [WalletActionCellType] in
                [.balance(assetBalanceViewPresenter)] +
                    presenters.map { WalletActionCellType.default($0) }
            }
            .map { cellTypes in
                [WalletActionItemsSectionViewModel(items: cellTypes)]
            }
            .asObservable()
            .bindAndCatch(to: sectionsRelay)
            .disposed(by: disposeBag)

        selectionRelay
            .bind { model in
                guard case .default(let presenter) = model else { return }
                switch presenter.action {
                case .receive:
                    stateService.receiveRelay.accept(())
                case .send:
                    stateService.sendRelay.accept(())
                case .buy:
                    stateService.buyRelay.accept(())
                case .sell:
                    stateService.sellRelay.accept(())
                case .activity:
                    stateService.activityRelay.accept(())
                case .deposit:
                    stateService.depositRelay.accept(())
                case .withdraw:
                    stateService.withdrawRelay.accept(())
                case .swap:
                    stateService.swapRelay.accept(())
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}

extension AssetAction {
    fileprivate var walletAction: WalletAction? {
        switch self {
        case .interestTransfer,
             .interestWithdraw,
             .sign,
             .stakingDeposit:
            return nil
        case .viewActivity:
            return .activity
        case .buy:
            return .buy
        case .deposit:
            return .deposit
        case .receive:
            return .receive
        case .sell:
            return .sell
        case .send:
            return .send
        case .swap:
            return .swap
        case .withdraw:
            return .withdraw
        }
    }
}
