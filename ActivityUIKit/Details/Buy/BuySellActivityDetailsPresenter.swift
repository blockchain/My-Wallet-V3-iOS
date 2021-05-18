//
//  BuySellActivityDetailsPresenter.swift
//  Blockchain
//
//  Created by Paulo on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
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
    private let disposeBag: DisposeBag = .init()

    // MARK: Private Properties (Model Relay)

    private let cardDataRelay: BehaviorRelay<CardData?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let totalCostPresenter: LineItemCellPresenting
    private let totalPresenter: LineItemCellPresenting
    private let sendingToPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting
    private let paymentMethodPresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    init(event: BuySellActivityItemEvent, interactor: BuySellActivityDetailsInteractor = .init()) {
        self.interactor = interactor
        self.event = event
        let title = event.isBuy ? LocalizedString.Title.buy : LocalizedString.Title.sell
        titleViewRelay.accept(.text(value: title))

        let paymentMethod: String
        switch event.paymentMethod {
        case .bankTransfer:
            paymentMethod = LocalizedLineItem.bankTransfer
        case .bankAccount:
            paymentMethod = LocalizedLineItem.bankTransfer
        case .card:
            paymentMethod = LocalizedLineItem.creditOrDebitCard
        case .funds:
            paymentMethod = "\(LocalizedLineItem.Funds.prefix) \(event.inputValue.currencyCode) \(LocalizedLineItem.Funds.suffix)"
        }
        let date = DateFormatter.elegantDateFormatter.string(from: event.creationDate)

        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        totalCostPresenter = TransactionalLineItem.totalCost(event.inputValue.displayString).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        totalPresenter = TransactionalLineItem.total(event.outputValue.displayString).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        let destination: String
        switch event.outputValue.currencyType {
        case .crypto:
            destination = "" // NOOP: impossible because this is only used for `Sell`, where destination is Fiat.
        case .fiat(let fiat):
            destination = fiat.defaultWalletName
        }
        sendingToPresenter = TransactionalLineItem.sendingTo(destination).defaultPresenter(
             accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        feePresenter = TransactionalLineItem.buyingFee(event.fee.displayString).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        paymentMethodPresenter = TransactionalLineItem.paymentMethod(paymentMethod).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        let amount = event.isBuy ? event.outputValue : event.inputValue
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: amount.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )
        badgesModel.badgesRelay.accept([statusBadge])
        let description = event.status.localizedDescription
        statusBadge.interactor.stateRelay.accept(
            .loaded(
                next: .init(
                    type: event.status == .failed ? .destructive : .default(accessibilitySuffix: description),
                    description: event.status.localizedDescription
                )
            )
        )
        cardDataRelay
            .compactMap { $0 }
            .map { "\($0.label) \($0.displaySuffix)" }
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: paymentMethodPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)
        
        switch event.isBuy {
        case true:
            cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(totalCostPresenter),
                .separator,
                .lineItem(feePresenter),
                .separator,
                .lineItem(paymentMethodPresenter)
            ]
        case false:
            cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(sendingToPresenter),
                .separator,
                .lineItem(feePresenter),
                .separator,
                .lineItem(paymentMethodPresenter)
            ]
        }
    }

    func viewDidLoad() {
        switch event.paymentMethod {
        case .bankTransfer:
            break
        case .bankAccount:
            break
        case .funds:
            break
        case .card(let paymentMethodId):
            interactor
                .fetchCardDetails(for: paymentMethodId)
                .asObservable()
                .catchErrorJustReturn(nil)
                .bindAndCatch(to: cardDataRelay)
                .disposed(by: disposeBag)
        }
    }
}

fileprivate extension BuySellActivityItemEvent.EventStatus {
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.OrderState
    var localizedDescription: String {
        switch self {
        case .pending:
            return LocalizedString.pending
        case .cancelled:
            return LocalizedString.cancelled
        case .failed:
            return LocalizedString.failed
        case .expired:
            return LocalizedString.expired
        case .finished:
            return LocalizedString.finished
        }
    }
}
