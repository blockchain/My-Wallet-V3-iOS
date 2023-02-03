// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureStakingDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

private typealias LocalizedString = LocalizationConstants.Activity.Details

final class InterestActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    private typealias BadgeType = BadgeItem.BadgeType
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
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting

    // MARK: - Init

    init(
        event: InterestActivityItemEvent,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        blockchainAccountRepository: BlockchainAccountRepositoryAPI = resolve()
    ) {
        let title: String
        switch event.type {
        case .withdraw:
            title = LocalizedString.Title.withdrawal
            let from = event.cryptoCurrency.code + " \(LocalizedString.rewardsAccount)"
            self.fromPresenter = TransactionalLineItem.from(from).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            self.toPresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(
                        knownValue: LocalizationConstants.LineItem.Transactional.to
                    ),
                    description: AccountNameLabelContentInteractor(
                        address: event.accountRef,
                        currencyType: .crypto(event.cryptoCurrency)
                    )
                ),
                accessibilityIdPrefix: ""
            )
        case .interestEarned:
            title = LocalizedString.Title.rewardsEarned
            let destination = event.cryptoCurrency.code + " \(LocalizedString.rewardsAccount)"
            self.fromPresenter = TransactionalLineItem.from(LocalizedString.companyName).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        case .transfer:
            title = LocalizedString.Title.added + " \(event.cryptoCurrency.displayCode)"
            let crypto = event.cryptoCurrency
            let name = crypto.name
            let destination = event.cryptoCurrency.code + " \(LocalizedString.rewardsAccount)"

            self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            if event.isInternalTransfer {
                self.fromPresenter = TransactionalLineItem
                    .from(name + " \(crypto.defaultTradingWalletName)")
                    .defaultPresenter(
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
            } else {
                self.fromPresenter = TransactionalLineItem
                    .from(name + " \(crypto.defaultWalletName)")
                    .defaultPresenter(
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
            }
        case .unknown:
            unimplemented()
        }
        titleViewRelay.accept(.text(value: title))

        self.cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.value.displayString,
            descriptors: .h1(accessibilityIdPrefix: "")
        )

        let statusDescription: String
        let badgeType: BadgeType
        switch event.state {
        case .complete:
            statusDescription = LocalizedString.completed
            badgeType = .verified
        case .manualReview:
            statusDescription = LocalizedString.manualReview
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .pending,
             .cleared,
             .processing:
            statusDescription = LocalizedString.pending
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .failed,
             .rejected:
            statusDescription = LocalizedString.failed
            badgeType = .destructive
        case .refunded,
             .unknown:
            unimplemented()
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

        let date = DateFormatter.elegantDateFormatter.string(from: event.insertedAt)
        self.dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.cells = [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(fromPresenter)
        ]
    }
}

final class AccountNameLabelContentInteractor: LabelContentInteracting {
    typealias InteractionState = LabelContent.State.Interaction

    private lazy var setup: Void = fetchNameOfAccountWithReceiveAddress(address)
        .asObservable()
        .map { .loaded(next: .init(text: $0)) }
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Properties

    private let blockchainAccountRepository: BlockchainAccountRepositoryAPI
    private let address: String
    private let currencyType: CurrencyType
    private let disposeBag = DisposeBag()

    init(
        blockchainAccountRepository: BlockchainAccountRepositoryAPI = resolve(),
        address: String,
        currencyType: CurrencyType
    ) {
        self.blockchainAccountRepository = blockchainAccountRepository
        self.address = address
        self.currencyType = currencyType
    }

    private func fetchNameOfAccountWithReceiveAddress(
        _ address: String
    ) -> AnyPublisher<String, Never> {
        blockchainAccountRepository
            .fetchAccountWithAddresss(
                address,
                currencyType: currencyType
            )
            .map(\.label)
            .replaceError(with: "\(currencyType.code) " + LocalizationConstants.wallet)
            .eraseToAnyPublisher()
    }
}

final class StakingActivityDetailsPresenter: DetailsScreenPresenterAPI {

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
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting

    // MARK: - Init

    init(
        product: EarnProduct,
        event: EarnActivity,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        blockchainAccountRepository: BlockchainAccountRepositoryAPI = resolve()
    ) {
        let title: String
        switch event.type {
        case .withdraw:
            title = LocalizedString.Title.withdrawal
            let from = event.currency.code + " \(product.account)"
            self.fromPresenter = TransactionalLineItem.from(from).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            self.toPresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(
                        knownValue: LocalizationConstants.LineItem.Transactional.to
                    ),
                    description: AccountNameLabelContentInteractor(
                        address: event.extraAttributes?.beneficiary?.accountRef ?? "?",
                        currencyType: event.currency
                    )
                ),
                accessibilityIdPrefix: ""
            )
        case .interestEarned:
            title = LocalizedString.Title.rewardsEarned
            let destination = event.currency.code + " \(product.account)"
            self.fromPresenter = TransactionalLineItem.from(LocalizedString.companyName).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        case .debit:
            title = LocalizedString.Title.debited
            let destination = event.currency.code + " \(product.account)"
            self.fromPresenter = TransactionalLineItem.from(LocalizedString.activeRewardsAccount).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
        case .deposit:
            switch product {
            case .staking:
                title = LocalizedString.Title.staked + " \(event.currency.displayCode)"
            case .active:
                title = LocalizedString.Title.subscribed + " \(event.currency.displayCode)"
            case _:
                title = LocalizedString.Title.added + " \(event.currency.displayCode)"
            }
            let crypto = event.currency.cryptoCurrency!
            let name = crypto.name
            let destination = event.currency.code + " \(product.account)"

            self.toPresenter = TransactionalLineItem.to(destination).defaultPresenter(
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            if event.extraAttributes?.isInternalTransfer == true {
                self.fromPresenter = TransactionalLineItem
                    .from(name + " \(crypto.defaultTradingWalletName)")
                    .defaultPresenter(
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
            } else {
                self.fromPresenter = TransactionalLineItem
                    .from(name + " \(crypto.defaultWalletName)")
                    .defaultPresenter(
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
            }
        case _:
            unimplemented()
        }
        titleViewRelay.accept(.text(value: title))

        self.cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.value.displayString,
            descriptors: .h1(accessibilityIdPrefix: "")
        )

        let statusDescription: String
        let badgeType: BadgeType
        switch event.state {
        case .complete:
            statusDescription = LocalizedString.completed
            badgeType = .verified
        case .manualReview:
            statusDescription = LocalizedString.manualReview
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .pending,
                .cleared,
                .processing:
            statusDescription = LocalizedString.pending
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .failed,
                .rejected:
            statusDescription = LocalizedString.failed
            badgeType = .destructive
        case _:
            unimplemented()
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

        self.orderIDPresenter = TransactionalLineItem.orderId(event.id).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let date = DateFormatter.elegantDateFormatter.string(from: event.date.insertedAt)
        self.dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.cells = [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(fromPresenter)
        ]
    }
}

extension EarnProduct {

    var account: String {
        switch self {
        case .savings:
            return LocalizedString.rewardsAccount
        case .staking:
            return LocalizedString.stakingAccount
        case .active:
            return LocalizedString.activeRewardsAccount
        case _:
            return LocalizedString.rewardsAccount
        }
    }
}
