// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI

/// Used for selecting a payment method in `Buy`
final class AccountAuxiliaryViewPresenter {

    // MARK: - Public Properites

    let badgeViewVisiblity: Driver<PlatformUIKit.Visibility>
    let badgeImageViewModel: Driver<BadgeImageViewModel>
    let titleLabel: Driver<LabelContent>
    let subtitleLabel: Driver<LabelContent>
    let badgeViewModel: Driver<BadgeViewModel>
    let buttonEnabled: Driver<Bool>
    let tapRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let interactor: AccountAuxiliaryViewInteractor

    init(interactor: AccountAuxiliaryViewInteractor) {
        self.interactor = interactor

        tapRelay
            .asSignal()
            .emit(to: interactor.auxiliaryViewTappedRelay)
            .disposed(by: disposeBag)

        self.buttonEnabled = interactor
            .state
            .map(\.isEnabled)

        self.badgeViewVisiblity = interactor
            .state
            .map(\.badgeViewModel)
            .map { $0.isNil ? .hidden : .visible }

        self.badgeViewModel = interactor
            .state
            .map(\.badgeViewModel)
            .map { $0.isNil ? .default(with: "") : $0! }

        self.badgeImageViewModel = interactor
            .state
            .map {
                ($0.imageResource, $0.imageBackgroundColor)
            }
            .map {
                BadgeImageViewModel.default(
                    image: $0,
                    backgroundColor: $1,
                    cornerRadius: .round,
                    accessibilityIdSuffix: "AccountAuxiliaryViewBadge"
                )
            }

        self.titleLabel = interactor
            .state
            .map(\.title)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 16.0),
                    color: .semantic.title,
                    alignment: .left,
                    accessibility: .id("AccountAuxiliaryViewTitle")
                )
            }

        self.subtitleLabel = interactor
            .state
            .map(\.subtitle)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.medium, 14.0),
                    color: .semantic.body,
                    alignment: .left,
                    accessibility: .id("AccountAuxiliaryViewSubtitle")
                )
            }
    }
}

extension AccountAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    func makeViewController() -> UIViewController {
        let accountAuxiliaryView = AccountAuxiliaryView()
        accountAuxiliaryView.presenter = self
        let viewController = UIViewController()
        viewController.view.addSubview(accountAuxiliaryView)
        accountAuxiliaryView.layoutToSuperview(.top)
        accountAuxiliaryView.layoutToSuperview(.bottom, offset: -Spacing.inner)
        accountAuxiliaryView.layoutToSuperview(.leading, offset: Spacing.outer)
        accountAuxiliaryView.layoutToSuperview(.trailing, offset: -Spacing.outer)
        return viewController
    }
}
