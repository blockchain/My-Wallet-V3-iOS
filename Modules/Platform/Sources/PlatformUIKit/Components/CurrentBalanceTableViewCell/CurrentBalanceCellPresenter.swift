// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxDataSources
import RxSwift

public final class CurrentBalanceCellPresenter: CurrentBalanceCellPresenting {

    public typealias DescriptionValue = () -> Observable<String>
    private typealias LocalizedString = LocalizationConstants.Dashboard.BalanceCell

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
        _ = setup
        return descriptionRelay.asDriver()
    }

    public var networkTitle: Driver<String?> {
        .just(nil)
    }

    public var pending: Driver<String> {
        .just(LocalizedString.pending)
    }

    public var pendingLabelVisibility: Driver<Visibility> {
        _ = setup
        return pendingLabelVisibilityRelay.asDriver()
    }

    public var separatorVisibility: Driver<Visibility> {
        separatorVisibilityRelay.asDriver()
    }

    var identifier: String {
        "\(accountType.description).\(currency.name)"
    }

    public let multiBadgeViewModel = MultiBadgeViewModel()

    public let viewAccessibilitySuffix: String
    public let titleAccessibilitySuffix: String
    public let descriptionAccessibilitySuffix: String
    public let pendingAccessibilitySuffix: String

    public let currency: CurrencyType
    public var accountType: SingleAccountType {
        interactor.accountType
    }

    public let assetBalanceViewPresenter: AssetBalanceViewPresenter

    // MARK: - Private Properties

    private lazy var setup: Void = {
        descriptionValue()
            .catchAndReturn("")
            .bindAndCatch(to: descriptionRelay)
            .disposed(by: disposeBag)

        interactor
            .assetBalanceViewInteractor
            .state
            .compactMap(\.value)
            .map {
                if let pendingValue = $0.pendingValue, !pendingValue.isZero {
                    return .visible
                } else {
                    return .hidden
                }
            }
            .catchAndReturn(.hidden)
            .bindAndCatch(to: pendingLabelVisibilityRelay)
            .disposed(by: disposeBag)
    }()

    private let badgeRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    private let separatorVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let iconImageViewContentRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    public let pendingLabelVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let interactor: CurrentBalanceCellInteracting
    private let descriptionValue: DescriptionValue

    private let disposeBag = DisposeBag()

    public init(
        interactor: CurrentBalanceCellInteracting,
        descriptionValue: @escaping DescriptionValue,
        currency: CurrencyType,
        separatorVisibility: Visibility = .hidden,
        viewAccessibilitySuffix: String,
        titleAccessibilitySuffix: String,
        descriptionAccessibilitySuffix: String,
        pendingAccessibilitySuffix: String,
        descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    ) {
        self.viewAccessibilitySuffix = viewAccessibilitySuffix
        self.titleAccessibilitySuffix = titleAccessibilitySuffix
        self.descriptionAccessibilitySuffix = descriptionAccessibilitySuffix
        self.pendingAccessibilitySuffix = pendingAccessibilitySuffix
        separatorVisibilityRelay.accept(separatorVisibility)
        self.interactor = interactor
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: .trailing,
            interactor: interactor.assetBalanceViewInteractor,
            descriptors: descriptors
        )
        self.currency = currency
        self.descriptionValue = descriptionValue

        switch currency {
        case .fiat(let fiatCurrency):
            let badgeImageViewModel: BadgeImageViewModel = .primary(
                image: fiatCurrency.logoResource,
                contentColor: .white,
                backgroundColor: fiatCurrency.brandColor,
                accessibilityIdSuffix: ""
            )
            badgeImageViewModel.marginOffsetRelay.accept(0)
            badgeRelay.accept(badgeImageViewModel)
        case .crypto(let cryptoCurrency):
            let badgeImageViewModel: BadgeImageViewModel = .default(
                image: cryptoCurrency.logoResource,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
            badgeImageViewModel.marginOffsetRelay.accept(0)
            badgeRelay.accept(badgeImageViewModel)
        }

        let model: BadgeImageViewModel
        switch (interactor.accountType, currency) {
        case (_, .fiat(let fiatCurrency)):
            model = .empty
            titleRelay.accept(fiatCurrency.defaultWalletName)
        case (.nonCustodial, .crypto(let cryptoCurrency)):
            model = .template(
                image: .local(name: "ic-private-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
            titleRelay.accept(cryptoCurrency.defaultWalletName)
        case (.custodial(.trading), .crypto(let cryptoCurrency)):
            model = .template(
                image: .local(name: "ic-trading-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
            titleRelay.accept(cryptoCurrency.defaultTradingWalletName)
        case (.custodial(.savings), .crypto(let cryptoCurrency)):
            model = .template(
                image: .local(name: "ic-interest-account", bundle: .platformUIKit),
                templateColor: currency.brandUIColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
            titleRelay.accept(cryptoCurrency.defaultInterestWalletName)
        }
        model.marginOffsetRelay.accept(1)
        iconImageViewContentRelay.accept(model)
    }
}
