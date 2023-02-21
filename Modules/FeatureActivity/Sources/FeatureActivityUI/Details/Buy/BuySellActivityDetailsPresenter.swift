// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class BuySellActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias LocalizedLineItem = LocalizationConstants.LineItem.Transactional
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel] = []

    let cells: [DetailsScreen.CellType]

    let titleViewRelay = BehaviorRelay<Screen.Style.TitleView>(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let event: BuySellActivityItemEvent
    private let interactor: BuySellActivityDetailsInteractor
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Private Properties (Model Relay)

    private let cardDataRelay: BehaviorRelay<String?> = .init(value: nil)
    private let recurringBuyNextPaymentDateRelay: BehaviorRelay<String?> = .init(value: nil)
    private let buyExchangeRateRelay: BehaviorRelay<MoneyValue?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let exchangeRatePresenter: LineItemCellPresenting
    private let totalPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting
    private let paymentMethodPresenter: LineItemCellPresenting
    private let recurringBuyFrequencyPresenter: LineItemCellPresenting

    init(
        event: BuySellActivityItemEvent,
        interactor: BuySellActivityDetailsInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.interactor = interactor
        self.event = event

        badgesModel.badgesRelay.accept([statusBadge])
        let description = event.status.localizedDescription
        let badgeType: BadgeAsset.Value.Interaction.BadgeItem.BadgeType
        switch event.status {
        case .pending:
            badgeType = .default(accessibilitySuffix: description)
            let title = event.isBuy ? LocalizedString.Title.buying : LocalizedString.Title.selling
            titleViewRelay.accept(.text(value: "\(title) \(event.currencyType.name)"))
        case .finished:
            badgeType = .verified
            let title = event.isBuy ? LocalizedString.Title.bought : LocalizedString.Title.sold
            titleViewRelay.accept(.text(value: "\(title) \(event.currencyType.name)"))
        default:
            badgeType = .destructive
            let title = event.isBuy ? LocalizedString.Title.buy : LocalizedString.Title.sell
            titleViewRelay.accept(.text(value: "\(title) \(event.currencyType.name)"))
        }
        statusBadge.interactor.stateRelay.accept(
            .loaded(
                next: .init(
                    type: badgeType,
                    description: description
                )
            )
        )

        let amount = event.isBuy ? event.outputValue : event.inputValue
        self.cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: amount.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )

        self.recurringBuyFrequencyPresenter = TransactionalLineItem
            .recurringBuyFrequency()
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)

        self.orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let date = DateFormatter.elegantDateFormatter.string(from: event.creationDate)
        self.dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        if event.isBuy {
            self.exchangeRatePresenter = TransactionalLineItem.exchangeRate().defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        } else {
            let pair = MoneyValuePair(base: event.inputValue, quote: event.outputValue)
            let exchangeRate = pair.exchangeRate
            let exchangeRateString = "\(exchangeRate.quote.displayString) / \(exchangeRate.base.displayCode)"
            self.exchangeRatePresenter = TransactionalLineItem.exchangeRate(exchangeRateString).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        }

        let total = event.isBuy ? event.inputValue.displayString : event.outputValue.displayString
        self.totalPresenter = TransactionalLineItem.total(total).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.feePresenter = TransactionalLineItem.fee(event.fee.displayString).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let paymentMethod: String
        switch event.paymentMethod {
        case .bankTransfer:
            paymentMethod = LocalizedLineItem.bankTransfer
        case .bankAccount:
            paymentMethod = LocalizedLineItem.bankTransfer
        case .card:
            paymentMethod = LocalizedLineItem.creditOrDebitCard
        case .applePay:
            paymentMethod = LocalizedLineItem.applePay
        case .funds:
            paymentMethod = event.inputValue.currency.name
        }
        self.paymentMethodPresenter = TransactionalLineItem.paymentMethod(paymentMethod).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        if event.recurringBuyId != nil {
            recurringBuyNextPaymentDateRelay
                .compactMap { $0 }
                .map { .loaded(next: .init(text: $0)) }
                .bindAndCatch(to: recurringBuyFrequencyPresenter.interactor.description.stateRelay)
                .disposed(by: disposeBag)
        }

        cardDataRelay
            .compactMap { $0 }
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: paymentMethodPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        buyExchangeRateRelay
            .compactMap { $0 }
            .map { [$0.displayString, event.outputValue.code].joined(separator: " / ") }
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: exchangeRatePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        let source = "\(event.inputValue.displayCode) \(LocalizedLineItem.Funds.suffix)"
        self.fromPresenter = TransactionalLineItem.from(source).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let destination: String
        switch event.outputValue.currencyType {
        case .crypto:
            destination = "" // NOOP: impossible because this is only used for `Sell`, where destination is Fiat.
        case .fiat(let fiat):
            destination = fiat.defaultWalletName
        }
        self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        switch event.isBuy {
        case true:
            var items: [DetailsScreen.CellType] = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(exchangeRatePresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(feePresenter),
                .separator,
                .lineItem(paymentMethodPresenter)
            ]
            if event.recurringBuyId != nil {
                items.append(.separator)
                items.append(.lineItem(recurringBuyFrequencyPresenter))
            }
            self.cells = items
        case false:
            self.cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(exchangeRatePresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(feePresenter),
                .separator,
                .lineItem(toPresenter),
                .separator,
                .lineItem(fromPresenter)
            ]
        }
    }

    func viewDidLoad() {
        if event.isBuy {
            interactor
                .fetchPrice(for: event.identifier)
                .asObservable()
                .bindAndCatch(to: buyExchangeRateRelay)
                .disposed(by: disposeBag)
        }

        switch event.paymentMethod {
        case .bankTransfer:
            break
        case .bankAccount:
            break
        case .funds:
            break
        case .applePay:
            break
        case .card(let paymentMethodId):
            interactor
                .fetchCardDisplayName(for: paymentMethodId)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] value in
                        self?.cardDataRelay.accept(value)
                    }
                )
                .store(in: &cancellables)
        }

        if let recurringBuyId = event.recurringBuyId {
            interactor
                .fetchRecurringBuyFrequencyForId(recurringBuyId)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [recurringBuyNextPaymentDateRelay] value in
                        recurringBuyNextPaymentDateRelay.accept(value)
                    }
                )
                .store(in: &cancellables)
        }
    }
}

extension BuySellActivityItemEvent.EventStatus {
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.OrderState
    fileprivate var localizedDescription: String {
        switch self {
        case .pending:
            return LocalizedString.pending
        case .finished:
            return LocalizedString.completed
        // Recurring buy only.
        default:
            return LocalizedString.failed
        }
    }
}
