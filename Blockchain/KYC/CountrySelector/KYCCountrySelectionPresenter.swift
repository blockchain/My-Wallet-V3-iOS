//
//  KYCCountrySelectionPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for the country selection view during the KYC flow
protocol KYCCountrySelectionView: class {

    /// Method invoked once the user selects a native KYC-supported country
    func continueKycFlow(country: KYCCountry)

    /// Method invoked when the user selects a country that isn't supported by
    /// Blockchain's native KYC. Instead, the user falls back to exchanging
    /// crypto-to-crypto using a partner (i.e. shapeshift)
    func startPartnerExchangeFlow(country: KYCCountry)

    /// Method invoked when the user selects a country that is not supported
    /// for exchanging crypto-to-crypto
    func showExchangeNotAvailable(country: KYCCountry)
}

class KYCCountrySelectionPresenter {

    // MARK: - Private Properties

    private let interactor: KYCCountrySelectionInteractor
    private let wallet: Wallet
    private let walletService: WalletService
    private weak var view: KYCCountrySelectionView?
    private let disposables = CompositeDisposable()

    // MARK: - Initializer

    init(
        view: KYCCountrySelectionView,
        interactor: KYCCountrySelectionInteractor = KYCCountrySelectionInteractor(),
        wallet: Wallet = WalletManager.shared.wallet,
        walletService: WalletService = WalletService.shared
    ) {
        self.view = view
        self.interactor = interactor
        self.wallet = wallet
        self.walletService = walletService
    }

    deinit {
        disposables.dispose()
    }

    // MARK: - Public Methods

    func selected(country: KYCCountry) {

        // Notify server of user's selection
        let interactorDisposable = interactor.selected(country: country)
        _ = disposables.insert(interactorDisposable)

        // There are 3 scenarios once a user picks a country:

        // 1. if the country is supported by our native KYC OR if the country has states, proceed
        if country.isKycSupported || country.states.count != 0 {
            Logger.shared.info("Selected country is supported by our native KYC.")
            view?.continueKycFlow(country: country)
            return
        }

        let stateCodeGuess = wallet.stateCodeGuess()
        let disposable = walletService.isInPartnerRegionForExchange(countryCode: country.code, state: stateCodeGuess)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                if $0 {
                    // 2. if the country is supported by shapeshift, use shapeshift
                    Logger.shared.info("Selected country can use shapeshift.")
                    self?.view?.startPartnerExchangeFlow(country: country)
                } else {
                    // 3. otherwise, tell the user crypto-crypto exchange is not available yet
                    Logger.shared.info("Country cannot perform crypto-crypto exchange.")
                    self?.view?.showExchangeNotAvailable(country: country)
                }
            })
        _ = disposables.insert(disposable)
    }
}
