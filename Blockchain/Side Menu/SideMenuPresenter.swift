//
//  SideMenuPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for a view that displays a list of
/// SideMenuItem objects.
protocol SideMenuView: class {
    func setMenu(items: [SideMenuItem])
}

/// Presenter for the side menu of the app. This presenter
/// will handle the logic as to what side menu items should be
/// presented in the SideMenuView.
class SideMenuPresenter {

    private weak var view: SideMenuView?
    private let wallet: Wallet
    private let walletService: WalletService

    private var disposable: Disposable?

    init(
        view: SideMenuView,
        wallet: Wallet = WalletManager.shared.wallet,
        walletService: WalletService = WalletService.shared
    ) {
        self.view = view
        self.wallet = wallet
        self.walletService = walletService
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func loadSideMenu() {
        guard let countryCodeGuess = wallet.countryCodeGuess() else {
            setMenuItems(showExchange: false)
            return
        }

        setMenuItems(showExchange: false)
        
        let stateCodeGuess = wallet.stateCodeGuess()
        
        let homebrewRegion = walletService.isCountryInHomebrewRegion(
            countryCode: countryCodeGuess
            ).asObservable()
        let partnerRegion = walletService.isInPartnerRegionForExchange(
            countryCode: countryCodeGuess,
            state: stateCodeGuess
            ).asObservable()
        
        disposable = Observable.combineLatest(BlockchainDataRepository.shared.nabuUser, homebrewRegion, partnerRegion) {
            return ($0, $1, $2)
            }.subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] payload in
                guard let this = self else { return }
                
                let user = payload.0
                let homebrewSupported = payload.1
                let partnerSupported = payload.2
                
                /// Any user, regardless of their location should see
                /// the exchange if they are approved.
                if user.status == .approved {
                    this.setMenuItems(showExchange: true)
                } else {
                    /// If the user is not approved, fall back on whether or not
                    /// the region is HB or partner supported. 
                    this.setMenuItems(
                        showExchange: homebrewSupported || partnerSupported
                    )
                }
            }, onError: { [weak self] error in
                guard let this = self else { return }
                Logger.shared.error("Failed to determine whether the country is supported by homebrew or by shapeshift.")
                this.setMenuItems(showExchange: false)
            })
    }

    private func setMenuItems(showExchange: Bool) {
        var items: [SideMenuItem] = []
        
        if wallet.isBuyEnabled() {
            items.append(.buyBitcoin)
        }
        if showExchange {
            items.append(.exchange)
        }
        if wallet.didUpgradeToHd() {
            items.append(.backup)
        } else {
            items.append(.upgrade)
        }
        items.append(contentsOf: [
            .settings,
            .accountsAndAddresses
            ]
        )
        if wallet.isLockboxEnabled() {
            items.append(.lockbox)
        }
        items.append(
            contentsOf: [
                .webLogin,
                .support,
                .logout
            ]
        )
        view?.setMenu(items: items)
    }
}
