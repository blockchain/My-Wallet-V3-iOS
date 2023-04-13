// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Combine
import DIKit
import Extensions
import Foundation
import Localization
import PlatformKit
import SwiftUI

public protocol RecoveryPhraseBackupRouterAPI {
    var completionSubject: PassthroughSubject<Void, Never> { get }
    var skipSubject: PassthroughSubject<Void, Never> { get }
    func presentFlow()
}

public class RecoveryPhraseBackupRouter: RecoveryPhraseBackupRouterAPI {
    public let completionSubject = PassthroughSubject<Void, Never>()
    public let skipSubject = PassthroughSubject<Void, Never>()
    let topViewController: TopMostViewControllerProviding
    private var recoveryStatusProviding: RecoveryPhraseStatusProviding
    private var isRecoveryPhraseVerified: Bool = false
    private var app: AppProtocol

    var step: Step = .backupIntro

    enum Step: Int {
        case backupIntro = 1
        case viewRecoveryPhrase = 2
        case manualBackupPhrase = 3
        case verifyBackupPhrase = 4
        case backupPhraseSuccess = 5

        mutating func next() {
            if let step = Step(rawValue: rawValue + 1) {
                self = step
            }
        }

        mutating func previous() {
            if let step = Step(rawValue: rawValue - 1) {
                self = step
            }
        }
    }

    enum Action {
        case next, back
    }

    public init(
        topViewController: TopMostViewControllerProviding,
        recoveryStatusProviding: RecoveryPhraseStatusProviding,
        app: AppProtocol = resolve()
    ) {
        self.topViewController = topViewController
        self.recoveryStatusProviding = recoveryStatusProviding
        self.app = app
    }

    public func presentFlow() {
        Task {
            do {
                isRecoveryPhraseVerified = await (try? recoveryStatusProviding.isRecoveryPhraseVerified.await()) ?? false
                step = isRecoveryPhraseVerified ? .viewRecoveryPhrase : .backupIntro
                await MainActor.run {
                    let navigationViewController = UINavigationController(rootViewController: self.view())
                    topViewController
                        .topMostViewController?
                        .present(navigationViewController, animated: true)
                }
            }
        }
    }

    func onNext() {
        step.next()
        topViewController
            .topMostViewController?
            .navigationController?
            .pushViewController(
                view(),
                animated: true
            )
    }

   @objc func onBack() {
        step.previous()
        topViewController
            .topMostViewController?
            .navigationController?
            .popViewController(animated: true)
    }

    @objc func onFailed() {
        let failedView = BackupRecoveryPhraseFailedView(store: .init(
            initialState: .init(),
            reducer: BackupRecoveryPhraseFailedModule.reducer,
            environment: .init(
              onConfirm: { [weak self] in
                  self?.skipFlow()
              }
            )
        )).app(app)

       topViewController
           .topMostViewController?
           .present(UIHostingController(rootView: failedView), animated: true)
    }

    @objc func onSkip() {
          let confirmView = BackupSkipConfirmView(store: .init(
              initialState: .init(),
              reducer: BackupSkipConfirmModule.reducer,
              environment: .init(
                onConfirm: { [weak self] in
                    self?.skipFlow()
                }
              )
          )).app(app)

         topViewController
             .topMostViewController?
             .present(UIHostingController(rootView: confirmView), animated: true)
     }

    @objc
    func onDone() {
        topViewController
            .topMostViewController?
            .dismiss(animated: true)
    }

    private func skipFlow() {
        topViewController
            .topMostViewController?
            .dismiss(animated: true, completion: { [weak self] in
                self?
                .topViewController
                .topMostViewController?
                .dismiss(animated: true, completion: {
                    self?.skipSubject.send(())
                })
        })
    }

    private func endFlow() {
        completionSubject.send(())
        topViewController
            .topMostViewController?
            .dismiss(animated: true)
    }

    func configureNavigationBar(for view: UIViewController) {
        let newBackButton = UIBarButtonItem(
            image: Icon.chevronLeft.uiImage,
            style: .plain,
            target: self,
            action: #selector(onBack)
        )

        let skipButton = UIBarButtonItem(
            title: LocalizationConstants.BackupRecoveryPhrase.skipButton,
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(onSkip)
        )

        view.navigationItem.leftBarButtonItem = newBackButton
        view.navigationItem.rightBarButtonItem = skipButton
    }

     func view() -> UIViewController
    {
        switch step {
        case .backupIntro:
           let view = ViewIntroBackupView(store: .init(
               initialState: .init(recoveryPhraseBackedUp: isRecoveryPhraseVerified),
               reducer: ViewIntroBackupModule.reducer,
               environment: .init(
                   onSkip: { [weak self] in
                       self?.onSkip()
                   },
                   onNext: { [weak self] in
                       self?.onNext()
                   }
               )
           )).app(app)

            let viewController = UIHostingController(rootView: view)
            let skipButton = UIBarButtonItem(
                title: LocalizationConstants.BackupRecoveryPhrase.skipButton,
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(onSkip)
            )

            viewController.navigationItem.rightBarButtonItem = skipButton
            return viewController

        case .viewRecoveryPhrase:
           let view = ViewRecoveryPhraseView(store: .init(
               initialState: .init(recoveryPhraseBackedUp: isRecoveryPhraseVerified),
               reducer: ViewRecoveryPhraseModule.reducer,
               environment: .init(
                   recoveryPhraseRepository: resolve(),
                   recoveryPhraseService: resolve(),
                   cloudBackupService: resolve(),
                   onNext: { [weak self] in
                       self?.onNext()
                   },
                   onDone: { [weak self] in
                       self?.onDone()
                   },
                   onFailed: { [weak self] in
                       self?.onFailed()
                   },
                   onIcloudBackedUp: { [weak self] in
                       self?.step = .backupPhraseSuccess
                       self?.onNext()
                   }
               )
           )).app(app)

            let viewController = UIHostingController(rootView: view)
            if isRecoveryPhraseVerified == false {
                configureNavigationBar(for: viewController)
            } else {
                let doneButton = UIBarButtonItem(
                    title: LocalizationConstants.BackupRecoveryPhrase.doneButton,
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(onDone)
                )

                viewController.navigationItem.rightBarButtonItem = doneButton
            }
            return viewController

        case .manualBackupPhrase:
            let view = ManualBackupSeedPhraseView(store: .init(
                initialState: .init(),
                reducer: ManualBackupSeedPhraseModule.reducer,
                environment: .init(
                    onNext: { [weak self] in
                        self?.onNext()
                    },
                    recoveryPhraseVerifyingService: resolve()
                )
            )).app(app)

            let viewController = UIHostingController(rootView: view)
            configureNavigationBar(for: viewController)
            return viewController

        case .verifyBackupPhrase:
            let view = VerifyRecoveryPhraseView(store: .init(
                initialState: .init(),
                reducer: VerifyRecoveryPhraseModule.reducer,
                environment: .init(
                    recoveryPhraseRepository: resolve(),
                    recoveryPhraseService: resolve(),
                    onNext: { [weak self] in
                        self?.onNext()
                    }
                )
            )).app(app)

            let viewController = UIHostingController(rootView: view)
            configureNavigationBar(for: viewController)
            return viewController

        case .backupPhraseSuccess:
            let view = BackupRecoveryPhraseSuccessView(store: .init(
                initialState: .init(),
                reducer: BackupRecoveryPhraseSuccessModule.reducer,
                environment: .init(
                    onNext: { [weak self] in
                        self?.endFlow()
                    }
                )
            )).app(app)

            let viewController = UIHostingController(rootView: view)
            return viewController
        }
    }
}
