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

    private let walletService: WalletService
    private weak var view: KYCCountrySelectionView?
    private var disposable: Disposable?

    // MARK: - Initializer

    init(view: KYCCountrySelectionView, walletService: WalletService = WalletService.shared) {
        self.view = view
        self.walletService = walletService
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    // MARK: - Public Methods

    func selected(country: KYCCountry) {
        // There are 3 scenarios once a user picks a country:

        // TODO: Update to use WalletService

        // 1. if the country is supported by our native KYC, proceed
        if country.isKycSupported {
            Logger.shared.info("Selected country is supported by our native KYC.")
            view?.continueKycFlow(country: country)
            return
        }

        // TODO: make sure to dispose disposable when moving to coordinator
        disposable = walletService.walletOptions
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] walletOptions in
                let shapeshiftBlacklistedCountries = walletOptions.shapeshift?.countriesBlacklist ?? []

                // TODO: check for state if selection is in the states
                if !shapeshiftBlacklistedCountries.contains(country.code) {
                    // 2. if the country is supported by shapeshift, use shapeshift
                    Logger.shared.info("Selected country can use shapeshift.")
                    self?.view?.startPartnerExchangeFlow(country: country)
                } else {
                    // 3. otherwise, tell the user crypto-crypto exchange is not available yet
                    Logger.shared.info("Country cannot perform crypto-crypto exchange.")
                    self?.view?.showExchangeNotAvailable(country: country)
                }
            })
    }
}
