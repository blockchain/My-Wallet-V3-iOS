// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import RxRelay
import RxSwift

open class DefaultBadgeAssetInteractor: BadgeAssetInteracting {
    public typealias InteractionState = BadgeAsset.State.BadgeItem.Interaction
    public typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem

    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    public let stateRelay: BehaviorRelay<InteractionState>
    public let disposeBag = DisposeBag()

    public init(initialState: InteractionState = .loading) {
        self.stateRelay = BehaviorRelay<InteractionState>(value: initialState)
    }
}
