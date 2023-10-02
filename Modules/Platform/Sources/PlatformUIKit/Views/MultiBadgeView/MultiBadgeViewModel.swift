// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public struct MultiBadgeViewModel {

    public let badgesRelay = BehaviorRelay<[BadgeAssetPresenting]>(value: [])
    public var badges: Driver<[BadgeAssetPresenting]> {
        badgesRelay.asDriver()
    }

    public let layoutMarginsRelay: BehaviorRelay<UIEdgeInsets>
    public var layoutMargins: Driver<UIEdgeInsets> {
        layoutMarginsRelay.asDriver()
    }

    public let heightRelay: BehaviorRelay<CGFloat>
    public var height: Driver<CGFloat> {
        Driver
            .zip(badges.map(\.isEmpty), heightRelay.asDriver())
            .map { isEmpty, height -> CGFloat in
                isEmpty ? 0.0 : height
            }
    }

    public var visibility: Driver<Visibility> {
        badges.map(\.isEmpty)
            .map { isEmpty -> Visibility in
                isEmpty ? .hidden : .visible
            }
    }

    public init(
        layoutMargins: UIEdgeInsets = .init(horizontal: 24.0, vertical: 24.0),
        height: CGFloat = 24,
        badges: [BadgeAssetPresenting] = []
    ) {
        self.layoutMarginsRelay = BehaviorRelay<UIEdgeInsets>(value: layoutMargins)
        self.heightRelay = BehaviorRelay<CGFloat>(value: height)
        badgesRelay.accept(badges)
    }
}
