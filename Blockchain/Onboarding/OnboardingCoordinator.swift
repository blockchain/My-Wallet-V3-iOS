//
//  OnboardingCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class OnboardingCoordinator {
    static let shared = OnboardingCoordinator()
    
    private init() {
    }
    
    // MARK: Public Methods
    
    func start() {
        showWelcomeScreen()
        checkAndWarnOnJailbrokenPhones()
    }
    
    // MARK: Private Methods
    
    private func showWelcomeScreen() {
        // TODO check for maintenance
        
        let welcomeView = BCWelcomeView()
        welcomeView.delegate = self
        ModalPresenter.shared.showModal(withContent: welcomeView, closeType: ModalCloseTypeNone, showHeader: false, headerText: "")
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func checkAndWarnOnJailbrokenPhones() {
        guard UIDevice.current.isUnsafe() else {
            return
        }
        // TODO: display alert
    }
}

extension OnboardingCoordinator: BCWelcomeViewDelegate {
    func showCreateWallet() {
        // TODO
    }
    
    func showPairWallet() {
        // TODO
    }
    
    func showRecoverWallet() {
        // TODO
    }
}
