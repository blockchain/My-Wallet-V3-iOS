// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

protocol BadgeImageAssetPresenting {
    var state: Observable<LoadingState<BadgeImageViewModel>> { get }
}

final class AddPaymenMethodBadgePresenter: BadgeImageAssetPresenting {

    typealias BadgeImageState = LoadingState<BadgeImageViewModel>

    var state: Observable<BadgeImageState> {
        _ = setup
        return stateRelay.asObservable()
    }

    private let stateRelay = BehaviorRelay<BadgeImageState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let interactor: AddPaymentMethodInteractor

    private lazy var setup: Void = {
        let paymentMethod = interactor.paymentMethod
        interactor.isEnabledForUser
            .map { isEnabledForUser in
                switch paymentMethod {
                case .bank:
                    return isEnabledForUser ? .bank : .info
                case .card:
                    return isEnabledForUser ? .card : .info
                }
            }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    init(interactor: AddPaymentMethodInteractor) {
        self.interactor = interactor
    }
}

private extension BadgeImageViewModel {

    static let bank: BadgeImageViewModel = .primary(
        with: "icon-bank",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )

    static let card: BadgeImageViewModel = .primary(
        with: "Icon-Creditcard",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )

    static let info: BadgeImageViewModel = .default(
        with: "Icon-Info",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )
}
