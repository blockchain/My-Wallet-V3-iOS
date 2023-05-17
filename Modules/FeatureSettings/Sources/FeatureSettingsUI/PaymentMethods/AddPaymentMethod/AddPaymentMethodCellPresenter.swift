// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableNavigation
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

final class AddPaymentMethodCellPresenter: AsyncPresenting {

    // MARK: - Exposed Properties

    var isLoading: Bool {
        isLoadingRelay.value
    }

    var action: SettingsScreenAction {
        actionTypeRelay.value
    }

    var addIconImageVisibility: Driver<Visibility> {
        imageVisibilityRelay.asDriver()
    }

    var descriptionLabelContent: LabelContent {
        LabelContent(
            text: localizedStrings.cta,
            font: .main(.medium, 16.0),
            color: .semantic.body
        )
    }

    var isAbleToAddNew: Observable<Bool> {
        interactor.isEnabledForUser
    }

    let badgeImagePresenter: BadgeImageAssetPresenting
    let labelContentPresenter: AddPaymentMethodLabelContentPresenter

    // MARK: - Private Properties

    private let imageVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let actionTypeRelay = BehaviorRelay<SettingsScreenAction>(value: .none)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    private let localizedStrings: AddPaymentMethodLocalizedStrings
    private let interactor: AddPaymentMethodInteractor

    init(interactor: AddPaymentMethodInteractor) {
        self.interactor = interactor
        self.localizedStrings = AddPaymentMethodLocalizedStrings(interactor.paymentMethod)

        self.labelContentPresenter = AddPaymentMethodLabelContentPresenter(
            interactor: AddPaymentMethodLabelContentInteractor(
                interactor: interactor,
                localizedStrings: localizedStrings
            )
        )
        self.badgeImagePresenter = AddPaymenMethodBadgePresenter(
            interactor: interactor
        )

        setup()
    }

    private func setup() {
        interactor.isEnabledForUser
            .map { $0 ? .visible : .hidden }
            .bindAndCatch(to: imageVisibilityRelay)
            .disposed(by: disposeBag)

        let paymentMethod = interactor.paymentMethod

        interactor.isEnabledForUser
            .map { isEnabled in
                guard isEnabled else { return .none }
                switch paymentMethod {
                case .card:
                    return .showAddCardScreen
                case .bank(let fiatCurrency):
                    return .showAddBankScreen(fiatCurrency)
                }
            }
            .bindAndCatch(to: actionTypeRelay)
            .disposed(by: disposeBag)

        badgeImagePresenter.state
            .map(\.isLoading)
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - IdentifiableType

extension AddPaymentMethodCellPresenter: IdentifiableType {
    var identity: String { localizedStrings.accessibilityId }
}
