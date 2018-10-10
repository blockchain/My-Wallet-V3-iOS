//
//  KYCStateSelectionPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Protocol definition for the state selection view during the KYC flow
protocol KYCStateSelectionView: class {

    /// Method invoked once the user selects a native KYC-supported state
    func continueKycFlow(state: KYCState)

    /// Method invoked when the user selects a state that is not supported
    /// for exchanging crypto-to-crypto
    func showExchangeNotAvailable(state: KYCState)

    /// Method invoked when the list of states should be displayed
    func display(states: [KYCState])
}

class KYCStateSelectionPresenter {

    private let interactor: KYCStateSelectionInteractor
    private weak var view: KYCStateSelectionView?
    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    init(view: KYCStateSelectionView, interactor: KYCStateSelectionInteractor = KYCStateSelectionInteractor()) {
        self.view = view
        self.interactor = interactor
    }

    func fetchStates(for country: KYCCountry) {
        disposable = interactor.fetchState(for: country)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] states in
                guard let strongSelf = self else { return }
                strongSelf.view?.display(states: states)
            }, onError: { error in
                Logger.shared.error("Failed to fetch states: \(error)")
            })
    }

    func selected(state: KYCState) {
        if state.isKycSupported {
            view?.continueKycFlow(state: state)
        } else {
            view?.showExchangeNotAvailable(state: state)
        }
    }
}
