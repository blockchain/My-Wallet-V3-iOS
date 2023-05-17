// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class RemovePaymentMethodScreenPresenter {

    // MARK: - Types

    typealias AccessibilityIDs = Accessibility.Identifier.Settings.RemovePaymentMethodScreen

    // MARK: - Properties

    let badgeImageViewModel: BadgeImageViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    let removeButtonViewModel: ButtonViewModel

    var dismissal: Signal<Void> {
        dismissalRelay.asSignal()
    }

    // MARK: - Private Properties

    private let loadingViewPresenter: LoadingViewPresenting
    private let interactor: RemovePaymentMethodScreenInteractor

    private let dismissalRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    init(
        buttonLocalizedString: String,
        interactor: RemovePaymentMethodScreenInteractor,
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.loadingViewPresenter = loadingViewPresenter
        self.interactor = interactor

        self.titleLabelContent = LabelContent(
            text: interactor.data.title,
            font: .main(.semibold, 20),
            color: .semantic.title,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.title)
        )

        self.descriptionLabelContent = LabelContent(
            text: interactor.data.description,
            font: .main(.medium, 14),
            color: .semantic.text,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.description)
        )

        let imageResource: ImageResource
        switch interactor.data.type {
        case .beneficiary:
            imageResource = interactor.data.icon.map(ImageResource.remote(url:)) ?? .local(name: "icon-bank", bundle: .platformUIKit)
        case .card(let type):
            imageResource = type.thumbnail ?? .local(name: "icon-card", bundle: .platformUIKit)
        }
        self.badgeImageViewModel = BadgeImageViewModel.default(
            image: imageResource,
            accessibilityIdSuffix: AccessibilityIDs.badge
        )
        badgeImageViewModel.marginOffsetRelay.accept(Spacing.standard)

        self.removeButtonViewModel = .destructive(with: buttonLocalizedString)
    }

    func viewDidLoad() {
        interactor.state
            .map(\.isCalculating)
            .bindAndCatch(weak: self) { (self, isCalculating) in
                if isCalculating {
                    self.loadingViewPresenter.show(with: .circle, text: nil)
                } else {
                    self.loadingViewPresenter.hide()
                }
            }
            .disposed(by: disposeBag)

        interactor.state
            .filter(\.isValue)
            .mapToVoid()
            .bindAndCatch(to: dismissalRelay)
            .disposed(by: disposeBag)

        removeButtonViewModel.tapRelay
            .bindAndCatch(to: interactor.triggerRelay)
            .disposed(by: disposeBag)
    }
}
