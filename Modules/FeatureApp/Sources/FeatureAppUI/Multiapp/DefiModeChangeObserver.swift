// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureAppDomain
import FeatureBackupRecoveryPhraseUI
import Foundation
import PlatformKit
import SwiftUI
import UIComponentsKit

public final class DefiModeChangeObserver: Client.Observer {
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

        observerBackupFundsRouter()
    }

    var observers: [AnyCancellable] {
        [
            userDidTapDefiMode
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

    lazy var userDidTapDefiMode = app.on(blockchain.ux.multiapp.chrome.switcher.defi.paragraph.button.minimal.tap)
        .receive(on: DispatchQueue.main)
        .sink(to: DefiModeChangeObserver.handleDefiModeTap(_:), on: self)

    func handleDefiModeTap(_ event: Session.Event) {
        Task {
            do {
                let recoveryPhraseBackedUp = try await recoveryPhraseStatusProviding.isRecoveryPhraseVerified.await()
                let recoveryPhraseSkipped = (try? await app.get(blockchain.user.skipped.seed_phrase.backup, as: Bool.self)) ?? false
                let userHasBeenDefaultedToPKW = (try? app.state.get(blockchain.app.mode.has.been.force.defaulted.to.mode, as: AppMode.self) == AppMode.pkw) ?? false
                let defiBalance = try await app.get(blockchain.ux.dashboard.total.defi.balance, as: BalanceInfo.self)

                let shouldShowDefiModeIntro = !(recoveryPhraseBackedUp || recoveryPhraseSkipped) && !userHasBeenDefaultedToPKW
                let shouldShowRecoveryFlow = !(recoveryPhraseBackedUp || recoveryPhraseSkipped) && userHasBeenDefaultedToPKW

                if defiBalance.balance.isPositive == false, shouldShowDefiModeIntro {
                    await MainActor.run {
                        presentDefiIntroScreen()
                    }
                } else if shouldShowRecoveryFlow {
                    showBackupSeedPhraseFlow()
                } else {
                    app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
                }
            } catch {
                app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
                app.post(error: error)
            }
        }
    }

    @MainActor
    func presentDefiIntroScreen() {
        let defiIntroScreen = DefiWalletIntroView(
            store: .init(
                initialState: .init(),
                reducer: DefiWalletIntro(
                    onDismiss: { [weak self] in
                        self?.dismissView()
                    }, onGetStartedTapped: { [weak self] in
                        self?.dismissView()
                        self?.showBackupSeedPhraseFlow()
                    }, app: resolve())
            )
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.topViewController.topMostViewController?.present(
                defiIntroScreen,
                inNavigationController: true
            )
        }
    }

    func showBackupSeedPhraseFlow() {
        backupFundsRouter.presentFlow()
    }

    func observerBackupFundsRouter() {
        backupFundsRouter
            .completionSubject
            .sink { [weak self] _ in
                self?.app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
            }
        .store(in: &cancellables)

        backupFundsRouter
            .skipSubject
            .sink { [weak self] _ in
                self?.app.state.set(blockchain.user.skipped.seed_phrase.backup, to: true)
                self?.app.post(value: AppMode.pkw.rawValue, of: blockchain.app.mode)
            }
        .store(in: &cancellables)
    }

    private func dismissView() {
        topViewController.topMostViewController?.dismiss(animated: true)
    }
}
