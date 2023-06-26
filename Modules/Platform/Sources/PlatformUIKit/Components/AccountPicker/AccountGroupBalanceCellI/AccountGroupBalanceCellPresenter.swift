// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift

public final class AccountGroupBalanceCellPresenter {

    typealias AccessibilityId = Accessibility.Identifier.Activity.WalletBalance

    // MARK: - Properties

    /// Returns the `Description`
    var description: Driver<LabelContent> {
        Driver.just(
            LabelContent(
                text: LocalizationConstants.Dashboard.Portfolio.totalBalance,
                font: .main(.medium, 14.0),
                color: .semantic.text,
                alignment: .left,
                accessibility: .id(AccessibilityId.description)
            )
        )
    }

    /// Returns the `Title`
    var title: Driver<LabelContent> {
        Driver.just(
            LabelContent(
                text: account.label,
                font: .main(.semibold, 16.0),
                color: .semantic.title,
                alignment: .left,
                accessibility: .id(AccessibilityId.title)
            )
        )
    }

    let accessibility: Accessibility = .id(AccessibilityId.cell)
    public let badgeImageViewModel: BadgeImageViewModel
    public let walletBalanceViewPresenter: WalletBalanceViewPresenter

    // MARK: - Private Properties

    public let account: AccountGroup
    private let interactor: AccountGroupBalanceCellInteractor
    private let imageViewVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)

    init(account: AccountGroup, interactor: AccountGroupBalanceCellInteractor) {
        self.account = account
        self.interactor = interactor
        self.walletBalanceViewPresenter = WalletBalanceViewPresenter(
            interactor: interactor.balanceViewInteractor
        )

        self.badgeImageViewModel = .primary(
            image: .local(name: "icon-wallet", bundle: .platformUIKit),
            contentColor: .semantic.background,
            cornerRadius: .none,
            accessibilityIdSuffix: "walletBalance"
        )
        badgeImageViewModel.marginOffsetRelay.accept(0)
    }
}
