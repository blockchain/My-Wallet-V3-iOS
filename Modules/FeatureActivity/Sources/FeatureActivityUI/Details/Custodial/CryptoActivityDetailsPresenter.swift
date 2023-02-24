// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay

final class CryptoActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    private typealias BadgeType = BadgeItem.BadgeType
    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias LocalizedLineItem = LocalizationConstants.LineItem.Transactional
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (Badge Model)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let totalPresenter: LineItemCellPresenting
    private let networkFeePresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting

    // MARK: - Init

    init(
        event: CustodialActivityEvent.Crypto,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        let title: String
        switch event.type {
        case .deposit:
            title = LocalizedString.Title.receive
        case .withdrawal:
            title = LocalizedString.Title.send
        }
        titleViewRelay.accept(.text(value: title))

        self.cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.amount.displayString,
            descriptors: .h1(accessibilityIdPrefix: "")
        )

        let statusDescription: String
        let badgeType: BadgeType
        switch event.state {
        case .completed:
            statusDescription = LocalizedString.completed
            badgeType = .verified
        case .pending:
            statusDescription = LocalizedString.pending
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .failed:
            statusDescription = LocalizedString.failed
            badgeType = .destructive
        }
        badgesModel.badgesRelay.accept([statusBadge])
        statusBadge.interactor.stateRelay.accept(
            .loaded(
                next: .init(
                    type: badgeType,
                    description: statusDescription
                )
            )
        )

        self.orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let date = DateFormatter.elegantDateFormatter.string(from: event.date)
        self.dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let totalValue = (try? event.amount.moneyValue + event.fee.moneyValue) ?? event.amount.moneyValue
        let total = totalValue.convert(using: event.price).displayString
        self.totalPresenter = TransactionalLineItem.total(total).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let fee = """
        \(event.fee.displayString) / \(event.fee.convert(using: event.price).displayString)
        """
        self.networkFeePresenter = TransactionalLineItem.networkFee(fee).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let destination: String
        switch event.type {
        case .deposit:
            destination = "\(event.amount.displayCode) \(LocalizedLineItem.tradingWallet)"
        case .withdrawal:
            destination = event.receivingAddress ?? "\(event.amount.displayCode) \(LocalizedLineItem.wallet)"
        }
        switch event.receivingAddress {
        case .none:
            self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        case .some:
            self.toPresenter = TransactionalLineItem.to(destination).defaultCopyablePresenter(
                analyticsRecorder: analyticsRecorder,
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        }

        let source: String
        switch event.type {
        case .deposit:
            source = "\(event.amount.displayCode) \(LocalizedLineItem.wallet)"
        case .withdrawal:
            source = "\(event.amount.displayCode) \(LocalizedLineItem.tradingWallet)"
        }
        self.fromPresenter = TransactionalLineItem.from(source).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        switch event.type {
        case .deposit:
            self.cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(toPresenter),
                .separator,
                .lineItem(fromPresenter)
            ]
        case .withdrawal:
            self.cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(networkFeePresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(toPresenter),
                .separator,
                .lineItem(fromPresenter)
            ]
        }
    }
}
