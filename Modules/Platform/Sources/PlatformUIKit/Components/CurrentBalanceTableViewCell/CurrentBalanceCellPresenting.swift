// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift

public protocol CurrentBalanceCellPresenting {
    var iconImageViewContent: Driver<BadgeImageViewModel> { get }

    var badgeImageViewModel: Driver<BadgeImageViewModel> { get }

    /// Returns the description of the balance
    var title: Driver<String> { get }

    /// Returns the description of the balance
    var description: Driver<String> { get }

    /// Returns the description of the balance
    var networkTitle: Driver<String?> { get }

    /// Returns the pending title
    var pending: Driver<String> { get }

    var pendingLabelVisibility: Driver<Visibility> { get }

    var separatorVisibility: Driver<Visibility> { get }

    var viewAccessibilitySuffix: String { get }

    var titleAccessibilitySuffix: String { get }

    var descriptionAccessibilitySuffix: String { get }

    var pendingAccessibilitySuffix: String { get }

    var assetBalanceViewPresenter: AssetBalanceViewPresenter { get }

    var multiBadgeViewModel: MultiBadgeViewModel { get }
}
