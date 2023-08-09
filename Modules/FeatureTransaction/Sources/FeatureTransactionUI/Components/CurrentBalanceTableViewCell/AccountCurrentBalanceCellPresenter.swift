// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

public final class AccountCurrentBalanceCellPresenter {

    private typealias AccessibilityId = Accessibility.Identifier.AccountPicker.AccountCell

    public var iconImageViewContent: Driver<BadgeImageViewModel> {
        iconImageViewContentRelay.asDriver()
    }

    public var badgeImageViewModel: Driver<BadgeImageViewModel> {
        badgeRelay.asDriver()
    }

    /// Returns the description of the balance
    public var title: Driver<String> {
        titleRelay.asDriver()
    }

    /// Returns the description of the balance
    public var description: Driver<String> {
        descriptionRelay.asDriver()
    }

    /// Returns the description of the balance
    public var networkTitle: Driver<String?> {
        networkTitleRelay.asDriver()
    }

    public var separatorVisibility: Driver<Visibility> {
        separatorVisibilityRelay.asDriver()
    }

    public let multiBadgeViewModel = MultiBadgeViewModel(
        layoutMargins: UIEdgeInsets(
            top: 8,
            left: 60,
            bottom: 16,
            right: 8
        ),
        height: 24
    )

    public let viewAccessibilitySuffix: String
    public let titleAccessibilitySuffix: String
    public let descriptionAccessibilitySuffix: String
    public let pendingAccessibilitySuffix: String

    public let assetBalanceViewPresenter: AssetBalanceViewPresenter

    // MARK: - Private Properties

    public let badgeRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    private let separatorVisibilityRelay: BehaviorRelay<Visibility>
    public let iconImageViewContentRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let networkTitleRelay = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    private let badgeFactory = SingleAccountBadgeFactory()
    private let enabledCurrencies: EnabledCurrenciesServiceAPI
    public let account: SingleAccount

    public init(
        account: SingleAccount,
        assetAction: AssetAction,
        interactor: AssetBalanceViewInteracting,
        enabledCurrencies: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default,
        separatorVisibility: Visibility = .visible
    ) {
        self.account = account
        self.separatorVisibilityRelay = BehaviorRelay<Visibility>(value: separatorVisibility)
        self.viewAccessibilitySuffix = "\(AccessibilityId.view)"
        self.titleAccessibilitySuffix = "\(AccessibilityId.titleLabel)"
        self.descriptionAccessibilitySuffix = "\(AccessibilityId.descriptionLabel)"
        self.pendingAccessibilitySuffix = "\(AccessibilityId.pendingLabel)"
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            interactor: interactor,
            descriptors: .default(
                cryptoAccessiblitySuffix: "\(AccessibilityId.cryptoAmountLabel)",
                fiatAccessiblitySuffix: "\(AccessibilityId.fiatAmountLabel)"
            )
        )
        self.enabledCurrencies = enabledCurrencies

        badgeFactory
            .badge(account: account, action: assetAction)
            .subscribe { [weak self] models in
                self?.multiBadgeViewModel.badgesRelay.accept(models)
            }
            .disposed(by: disposeBag)

        let badgeImageModel = SingleAccountBadgeImageViewModel
            .badgeModel(account: account)
        badgeRelay.accept(badgeImageModel)

        let iconImageModel = SingleAccountBadgeImageViewModel
            .iconModel(account: account, action: assetAction)
        iconImageViewContentRelay.accept(iconImageModel ?? .empty)

        titleRelay.accept(account.assetName)
        if account is TradingAccount {
            descriptionRelay.accept("")
        } else if account is NonCustodialAccount {
            if assetAction == .send {
                titleRelay.accept(account.label)
                descriptionRelay.accept(account.currencyType.displayCode)
                if let cryptoCurrency = account.currencyType.cryptoCurrency {
                    networkTitleRelay.accept(
                        enabledCurrencies.network(for: cryptoCurrency)?.networkConfig.shortName
                    )
                }
            } else {
                descriptionRelay.accept(account.assetName)
            }
        } else {
            descriptionRelay.accept(account.currencyType.displayCode)
        }
    }
}

extension AccountCurrentBalanceCellPresenter: Equatable {
    public static func == (lhs: AccountCurrentBalanceCellPresenter, rhs: AccountCurrentBalanceCellPresenter) -> Bool {
        lhs.account.identifier == rhs.account.identifier
    }
}
