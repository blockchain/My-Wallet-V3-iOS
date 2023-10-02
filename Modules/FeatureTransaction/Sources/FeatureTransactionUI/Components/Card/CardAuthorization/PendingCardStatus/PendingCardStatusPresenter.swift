// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import ErrorsUI
import Localization
import RIBs
import RxCocoa
import RxSwift
import ToolKit

final class PendingCardStatusPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.PendingCardStatusScreen

    // MARK: - Properties

    var viewModel: Driver<PendingStateViewModel> = .empty()
    var error: Driver<UX.Error> {
        errorRelay
            .asDriver()
            .compactMap { $0 }
    }

    private let errorRelay = BehaviorRelay<UX.Error?>(value: nil)

    private let interactor: PendingCardStatusInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: PendingCardStatusInteractor) {
        self.interactor = interactor
        super.init(interactable: interactor)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        interactor.startPolling()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] state in
                    self?.handle(state: state)
                },
                onFailure: { [weak self] error in
                    self?.handle(state: .inactive(error))
                }
            )
            .disposed(by: disposeBag)
    }

    private func handle(state: PendingCardStatusInteractor.State) {
        switch state {
        case .active(let cardData):
            interactor.endWithConfirmation(with: cardData)
        case .inactive(let error):
            errorRelay.accept(UX.Error(error: error))
        case .timeout:
            errorRelay.accept(
                UX.Error(
                    title: LocalizedString.Error.title,
                    message: LocalizedString.Error.subtitle,
                    icon: URL(string: LocalizedString.Error.icon).map(UX.Icon.init(url:))
                )
            )
        }
    }
}
