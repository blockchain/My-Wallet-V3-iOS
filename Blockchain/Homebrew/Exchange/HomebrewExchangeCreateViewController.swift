//
//  HomebrewExchangeCreateViewController.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class HomebrewExchangeCreateViewController: UIViewController {

    // MARK: Public Properties

    weak var delegate: ExchangeTradeDelegate?

    // MARK: Private Properties

    fileprivate var tradeCoordinator: ExchangeTradeCoordinator!
    fileprivate var exchangeCreateView: ExchangeCreateView!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tradeCoordinator = ExchangeTradeCoordinator(interface: self)

        let exchangeCreateView = ExchangeCreateView(frame: view.bounds)
        view.addSubview(exchangeCreateView)

        let fromToButtonCoordinator = FromToButtonDelegateIntermediate(
            wallet: WalletManager.shared.wallet,
            navigationController: self.navigationController as! BCNavigationController,
            addressSelectionDelegate: self
        )
        exchangeCreateView.setup(
            createViewDelegate: self,
            fromToButtonDelegate: fromToButtonCoordinator,
            continueButtonInputAccessoryDelegate: self,
            textFieldDelegate: self
        )
    }
}

extension HomebrewExchangeCreateViewController: ExchangeTradeInterface {
    func continueButtonEnabled(_ enabled: Bool) {
        if enabled {
            exchangeCreateView.enablePaymentButtons()
        } else {
            exchangeCreateView.disablePaymentButtons()
        }
    }
}

extension HomebrewExchangeCreateViewController: ExchangeCreateViewDelegate {
    func assetToggleButtonClicked() {
    }

    func useMinButtonClicked() {
    }

    func useMaxButtonClicked() {
    }

    func continueButtonClicked() {
        delegate?.onContinueButtonClicked()
    }
}

extension HomebrewExchangeCreateViewController: ContinueButtonInputAccessoryViewDelegate {
    func closeButtonClicked() {
        exchangeCreateView.hideKeyboard()
    }
}

extension HomebrewExchangeCreateViewController: UITextFieldDelegate {

}

extension HomebrewExchangeCreateViewController: AddressSelectionDelegate {

}
