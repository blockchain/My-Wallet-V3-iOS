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
        disposable = Observable.combineLatest(
            walletService.isCountryInHomebrewRegion(countryCode: countryCodeGuess).asObservable(),
            walletService.isInPartnerRegionForExchange(countryCode: countryCodeGuess, state: stateCodeGuess).asObservable()
        ).subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (isHomebrewSupported, isPartnerSupported) in
                self.setMenuItems(showExchange: isHomebrewSupported || isPartnerSupported)
            }, onError: { [unowned self] error in
                Logger.shared.error("Failed to determine whether the country is supported by homebrew or by shapeshift.")
                self.setMenuItems(showExchange: true)
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
            .accountsAndAddresses,
            .webLogin,
            .support,
            .logout
        ])
        #if DEBUG
        items.append(.kyc)
        #endif
        view?.setMenu(items: items)
    }
}
