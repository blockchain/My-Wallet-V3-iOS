// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import SettingsKit

final class TierLimitsLabelContentInteractor: LabelContentInteracting {

    // MARK: - Types

    typealias InteractionState = LabelContent.State.Interaction

    // MARK: - Properties

    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Setup 

    init(limitsProviding: TierLimitsProviding) {
        limitsProviding.tiers
            .map { _ in .loaded(next: .init(text: LocalizationConstants.KYC.accountLimits)) }
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
