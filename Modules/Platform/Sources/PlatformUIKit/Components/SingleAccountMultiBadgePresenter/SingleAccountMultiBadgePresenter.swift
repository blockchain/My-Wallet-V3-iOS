// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import RxCocoa
import RxSwift

public final class SingleAccountMultiBadgePresenter {

    static let multiBadgeInsets: UIEdgeInsets = .init(
        top: 0,
        left: 72,
        bottom: 0,
        right: 0
    )

    public let model: Driver<MultiBadgeViewModel>

    private let badgeFactory = SingleAccountBadgeFactory()

    public init(account: SingleAccount, action: AssetAction) {
        self.model = badgeFactory
            .badge(account: account, action: action)
            .asDriver(onErrorJustReturn: [])
            .map {
                MultiBadgeViewModel(
                    layoutMargins: Self.multiBadgeInsets,
                    height: 24,
                    badges: $0
                )
            }
    }
}
