// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetBalanceViewPresenter {

    public typealias PresentationState = AssetBalanceViewModel.State.Presentation

    // MARK: - Exposed Properties

    public var state: Observable<PresentationState> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
    }

    // MARK: - Private Properties

    private lazy var setup: Void = {
        // Map interaction state into presentation state
        //  and bind it to `stateRelay`.
        interactor
            .state
            .catchAndReturn(.loading)
            .map { [descriptors] state in
                PresentationState(
                    with: state,
                    descriptors: descriptors
                )
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let interactor: AssetBalanceViewInteracting
    private let descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Init

    public init(
        interactor: AssetBalanceViewInteracting,
        descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    ) {
        self.interactor = interactor
        self.descriptors = descriptors
    }
}
