//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import DIKit
import SwiftUI
import UIKit

public final class MultiAppRootController: UIHostingController<MultiAppContainerChrome> {

    let app: AppProtocol
    let global: ViewStore<LoggedIn.State, LoggedIn.Action>

    let siteMap: SiteMap

    var appStoreReview: AnyCancellable?
    var bag: Set<AnyCancellable> = []

    public init(
        store global: Store<LoggedIn.State, LoggedIn.Action>,
        app: AppProtocol,
        siteMap: SiteMap
    ) {
        self.global = ViewStore(global)
        self.app = app
        self.siteMap = siteMap
        super.init(rootView: MultiAppContainerChrome(app: app))

        setupNavigationObservers()
    }

    public func clear() {
        bag.removeAll()
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
