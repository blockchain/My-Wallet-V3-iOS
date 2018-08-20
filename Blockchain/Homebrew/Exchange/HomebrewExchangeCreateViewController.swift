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

        exchangeCreateView = ExchangeCreateView(frame: view.bounds)
        view.addSubview(exchangeCreateView)

        exchangeCreateView.setup(
            withConversionView: true,
            delegate: self,
            navigationController: self.navigationController as! BCNavigationController
        )
        LoadingViewPresenter.shared.hideBusyView()
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
    func assetToggleButtonTapped() {
    }

    func useMinButtonTapped() {
    }

    func useMaxButtonTapped() {
    }

    func continueButtonTapped() {
        delegate?.onContinueButtonTapped()
    }
}

extension HomebrewExchangeCreateViewController: ContinueButtonInputAccessoryViewDelegate {
    func closeButtonTapped() {
        exchangeCreateView.hideKeyboard()
    }
}

extension HomebrewExchangeCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

extension HomebrewExchangeCreateViewController: AddressSelectionDelegate {
    func getAssetType() -> LegacyAssetType {
        return LegacyAssetType(rawValue: -1)!
    }

    func didSelect(fromAccount account: Int32, assetType asset: LegacyAssetType) {

    }

    func didSelect(toAccount account: Int32, assetType asset: LegacyAssetType) {

    }
}
