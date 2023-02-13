// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureBackupRecoveryPhraseUI
import Foundation
import PlatformKit
import SwiftUI
import UIComponentsKit

public final class DashboardAnnouncementsObserver: Client.Observer {
    unowned let app: AppProtocol
    let topViewController: TopMostViewControllerProviding
    public let recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    public let backupFundsRouter: RecoveryPhraseBackupRouterAPI

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        topViewController: TopMostViewControllerProviding = DIKit.resolve(),
        recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding = DIKit.resolve(),
        backupFundsRouter: RecoveryPhraseBackupRouterAPI = DIKit.resolve()
    ) {
        self.app = app
        self.topViewController = topViewController
        self.recoveryPhraseStatusProviding = recoveryPhraseStatusProviding
        self.backupFundsRouter = backupFundsRouter

        observeBackupFundsRouter()
    }

    var observers: [AnyCancellable] {
        [
            userDidTapBackupSeedPhraseAnnouncement
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

    lazy var userDidTapBackupSeedPhraseAnnouncement = app.on(blockchain.ux.home.dashboard.announcement.backup.seed.phrase)
        .receive(on: DispatchQueue.main)
        .sink(to: DashboardAnnouncementsObserver.handleBackupSeedPhraseTap(_:), on: self)

    func handleBackupSeedPhraseTap(_ event: Session.Event) {
        showBackupSeedPhraseFlow()
    }

    func showBackupSeedPhraseFlow() {
        backupFundsRouter.presentFlow()
    }

    func observeBackupFundsRouter() {
        backupFundsRouter
            .completionSubject
            .sink { [weak self] _ in}
        .store(in: &cancellables)

        backupFundsRouter
            .skipSubject
            .sink { [weak self] _ in
                self?.app.state.set(blockchain.user.skipped.seed_phrase.backup, to: true)
            }
        .store(in: &cancellables)
    }

    private func dismissView() {
        topViewController.topMostViewController?.dismiss(animated: true)
    }
}
