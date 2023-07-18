// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public protocol AssetBalanceViewInteracting: AnyObject {
    var state: Observable<AssetBalanceViewModel.State.Interaction> { get }

    func refresh()
}
