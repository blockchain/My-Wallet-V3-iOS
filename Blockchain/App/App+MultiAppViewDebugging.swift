// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureBackupRecoveryPhraseUI
import FeatureDashboardUI
import FeatureSuperAppIntroUI
import Foundation
import SwiftUI
import UIComponentsKit

public final class MultiAppViewDebuggingObserver: Client.Observer {
    unowned let app: AppProtocol
    let topViewController: TopMostViewControllerProviding

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.topViewController = topViewController
    }

    var observers: [AnyCancellable] {
        [
            allAssetsScreenPresent
        ]
    }

    public func start() {
        for observer in observers {
            observer.store(in: &cancellables)
        }
    }

    public func stop() {
        cancellables = []
    }

    lazy var allAssetsScreenPresent = app.on(blockchain.ux.multiapp.present.allAssetsScreen)
        .receive(on: DispatchQueue.main)
        .sink(to: MultiAppViewDebuggingObserver.showAllAssetsScreen(_:), on: self)

    func showAllAssetsScreen(_ event: Session.Event) {
        presentAllAssetsScreen()
    }

    private func presentAllAssetsScreen() {
        let view = AllAssetsSceneView(store: .init(
            initialState: .init(with: .custodial),
            reducer: AllAssetsScene(
                assetBalanceInfoRepository: resolve(),
                app: resolve()
            )
        ))

        topViewController.topMostViewController?.present(
            view,
            inNavigationController: false,
            modalPresentationStyle: UIModalPresentationStyle.fullScreen
        )
    }
}
