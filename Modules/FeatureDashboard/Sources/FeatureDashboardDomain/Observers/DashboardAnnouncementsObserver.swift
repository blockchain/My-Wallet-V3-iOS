// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureBackupRecoveryPhraseUI
import Foundation

public final class DashboardAnnouncementsObserver: Client.Observer {
    private unowned let app: AppProtocol
    private let backupFundsRouter: RecoveryPhraseBackupRouterAPI
    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        backupFundsRouter: RecoveryPhraseBackupRouterAPI
    ) {
        self.app = app
        self.backupFundsRouter = backupFundsRouter
        observeBackupFundsRouter()
    }

    public func start() {
        for observer in observers {
            observer.store(in: &cancellables)
        }
    }

    public func stop() {
        cancellables = []
    }

    private var observers: [AnyCancellable] {
        [
            userDidTapBackupSeedPhraseAnnouncement
        ]
    }

    private lazy var userDidTapBackupSeedPhraseAnnouncement = app
        .on(blockchain.ux.home.dashboard.announcement.backup.seed.phrase)
        .receive(on: DispatchQueue.main)
        .sink(to: DashboardAnnouncementsObserver.handleBackupSeedPhraseTap(_:), on: self)

    private func handleBackupSeedPhraseTap(_ event: Session.Event) {
        backupFundsRouter.presentFlow()
    }

    private func observeBackupFundsRouter() {
        backupFundsRouter
            .completionSubject
            .sink { _ in }
            .store(in: &cancellables)

        backupFundsRouter
            .skipSubject
            .sink { [weak self] _ in
                self?.app.state.set(blockchain.user.skipped.seed_phrase.backup, to: true)
            }
            .store(in: &cancellables)
    }
}
