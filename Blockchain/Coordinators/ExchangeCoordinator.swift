//
//  ExchangeCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class ExchangeCoordinator: NSObject, Coordinator {

    private enum ExchangeType: Int {
        case homebrew
        case shapeshift
    }

    static let shared = ExchangeCoordinator()

    private let walletManager: WalletManager

    private let walletService: WalletService

    private var disposable: Disposable?

    private init(
        walletManager: WalletManager = WalletManager.shared,
        walletService: WalletService = WalletService.shared
        ) {
        self.walletManager = walletManager
        self.walletService = walletService
        super.init()
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func start() {
        if WalletManager.shared.wallet.hasEthAccount() {
            let success = { (isHomebrewAvailable: Bool) in
                if isHomebrewAvailable {
                    self.showExchange(type: .homebrew)
                } else {
                    self.showExchange(type: .shapeshift)
                }
            }
            let error = { (error: Error) in
                print("Error checking if homebrew is available: \(error) - showing shapeshift")
                self.showExchange(type: .shapeshift)
            }
            checkForHomebrewAvailability(success: success, error: error)
        } else {
            if WalletManager.shared.wallet.needsSecondPassword() {
                AuthenticationCoordinator.shared.showPasswordConfirm(withDisplayText: LocalizationConstants.Authentication.etherSecondPasswordPrompt,
                 headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                 validateSecondPassword: true) { (secondPassword) in
                    WalletManager.shared.wallet.createEthAccount(forExchange: secondPassword)
                }
            } else {
                WalletManager.shared.wallet.createEthAccount(forExchange: nil)
            }
        }
    }

    private func checkForHomebrewAvailability(success: @escaping (Bool) -> Void, error: @escaping (Error) -> Void) {
        guard let countryCode = WalletManager.sharedInstance().wallet.countryCodeGuess() else {
            error(WalletServiceError.generic(message: "No country code found"))
            return
        }

        LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.Exchange.loading)

        disposable = walletService.isCountryInHomebrewRegion(countryCode: countryCode)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: success, onError: error)
    }

    private func showExchange(type: ExchangeType) {
        switch type {
        case .homebrew: AppCoordinator.shared.tabControllerManager.showHomebrew()
        default: AppCoordinator.shared.tabControllerManager.showShapeshift()
        }
    }
}
