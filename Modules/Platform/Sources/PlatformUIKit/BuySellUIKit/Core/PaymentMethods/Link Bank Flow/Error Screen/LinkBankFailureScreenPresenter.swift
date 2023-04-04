// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxSwift

final class LinkBankFailureScreenPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.LinkBankScreen

    // MARK: - Properties

    var viewModel: Driver<PendingStateViewModel> = .empty()
    var error: Driver<UX.Error> = .empty()

    // MARK: - Private Properties

    private let interactor: LinkBankFailureScreenInteractor
    private let disposeBag = DisposeBag()

    init(interactor: LinkBankFailureScreenInteractor) {
        self.interactor = interactor
        super.init(interactable: interactor)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonModel = ButtonViewModel.primary(with: LocalizedString.GenericFailure.tryAgainButtonTitle)
        buttonModel.tap
            .emit(to: interactor.continueTapped)
            .disposeOnDeactivate(interactor: interactor)

        let cancelButtonModel = ButtonViewModel.secondary(with: LocalizedString.GenericFailure.cancelActionButtonTitle)

        cancelButtonModel.tap
            .emit(to: interactor.cancelTapped)
            .disposeOnDeactivate(interactor: interactor)

        viewModel = Driver.deferred { [weak self] () -> Driver<PendingStateViewModel> in
            guard let self else { return .empty() }
            return .just(errorViewModel(buttonModel: buttonModel, canceButtonModel: cancelButtonModel))
        }
    }

    // MARK: - View Model Providers

    private func errorViewModel(buttonModel: ButtonViewModel, canceButtonModel: ButtonViewModel) -> PendingStateViewModel {
        PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(.local(name: "large-bank-icon", bundle: .platformUIKit)),
                    sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.circleError.imageResource), position: .rightCorner)
                )
            ),
            title: LocalizedString.GenericFailure.title,
            subtitle: LocalizedString.GenericFailure.subtitle,
            button: buttonModel,
            supplementaryButton: canceButtonModel
        )
    }
}
