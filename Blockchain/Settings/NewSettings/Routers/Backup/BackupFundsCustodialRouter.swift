//
//  BackupFundsCustodialRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class BackupFundsCustodialRouter: BackupRouterAPI {
    
    // MARK: - BackupRouterAPI
    
    let entry: BackupRouterEntry = .custody
    let completionRelay = PublishRelay<Void>()
    
    private let navigationRouter: NavigationRouterAPI
    private var stateService: BackupRouterStateService!
    private let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    private let disposeBag = DisposeBag()
    
    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         recoveryPhraseVerifying: RecoveryPhraseVerifyingServiceAPI = resolve()) {
        self.recoveryPhraseVerifyingService = recoveryPhraseVerifying
        self.navigationRouter = navigationRouter
    }
    
    func start() {
        stateService = BackupRouterStateService(entry: entry)
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                case .complete:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: { [weak self] in
                        guard let self = self else { return }
                        self.completionRelay.accept(())
                    })
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: BackupRouterStateService.State) {
        switch state {
        case .start, .end:
            break
        case .backupFunds(let presentationType, let entry):
            showBackupFunds(presentationType: presentationType, entry: entry)
        case .recovery:
            let presenter = RecoveryPhraseScreenPresenter(
                stateService: stateService,
                recoveryPhraseVerifying: recoveryPhraseVerifyingService
                )
            let controller = RecoveryPhraseViewController(presenter: presenter)
            navigationRouter.navigationControllerAPI?.pushViewController(controller, animated: true)
        case .verification:
            let presenter = VerifyBackupScreenPresenter(
                stateService: stateService,
                service: recoveryPhraseVerifyingService
            )
            let controller = VerifyBackupViewController(presenter: presenter)
            navigationRouter.navigationControllerAPI?.pushViewController(controller, animated: true)
        }
    }
    
    func previous() {
        navigationRouter.dismiss()
    }
    
    // MARK: - Private Functions
    
    private func showBackupFunds(presentationType: PresentationType, entry: BackupRouterEntry) {
        let presenter = BackupFundsScreenPresenter(stateService: stateService, entry: entry)
        let controller = DetailsScreenViewController(presenter: presenter)
        controller.isModalInPresentation = true
        navigationRouter.present(viewController: controller, using: presentationType)
    }
}
