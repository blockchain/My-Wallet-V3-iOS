// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift

public final class PaymentMethodCellPresenter {

    // MARK: - Public Properties

    public let account: PaymentMethodAccount
    let badgeImageViewModel: Driver<BadgeImageViewModel>
    let title: Driver<LabelContent>
    let description: Driver<LabelContent>
    public let multiBadgeViewModel: Driver<MultiBadgeViewModel>

    // MARK: - Private Properties

    static let multiBadgeInsets: UIEdgeInsets = .init(
        top: 0,
        left: 72,
        bottom: 0,
        right: 0
    )
    private let badgeFactory = SingleAccountBadgeFactory()

    // MARK: - Init

    public init(account: PaymentMethodAccount, action: AssetAction) {
        self.account = account

        self.multiBadgeViewModel = badgeFactory
            .badge(account: account, action: action)
            .map {
                .init(
                    layoutMargins: LinkedBankAccountCellPresenter.multiBadgeInsets,
                    height: 24.0,
                    badges: $0
                )
            }
            .asDriver(onErrorJustReturn: .init())

        self.title = .just(
            .init(
                text: account.label,
                font: .main(.semibold, 16.0),
                color: .semantic.title,
                alignment: .left,
                accessibility: .none
            )
        )
        self.description = .just(
            .init(
                text: account.paymentMethodType.balance.displayString,
                font: .main(.medium, 14.0),
                color: .semantic.text,
                alignment: .left,
                accessibility: .none
            )
        )
        self.badgeImageViewModel = .just(.default(
            image: account.logoResource,
            backgroundColor: account.logoBackgroundColor,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        ))
    }
}
