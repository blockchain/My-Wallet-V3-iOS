//
//  ExchangeCreateViewController.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeCreateViewController: UIViewController {

    // MARK: Public Properties

    weak var delegate: ExchangeCreateDelegate?

    // MARK: Private Properties

    fileprivate var exchangeCreateView: ExchangeCreateView!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        exchangeCreateView = ExchangeCreateView(frame: view.bounds)
        view.addSubview(exchangeCreateView)

        exchangeCreateView.setup(
            delegate: self,
            navigationController: self.navigationController as! BCNavigationController
        )
    }
}

extension ExchangeCreateViewController: ExchangeCreateInterface {
    func continueButtonEnabled(_ enabled: Bool) {
        if enabled {
            exchangeCreateView.enablePaymentButtons()
        } else {
            exchangeCreateView.disablePaymentButtons()
        }
    }

    func exchangeRateUpdated(_ rate: String) {

    }
}

extension ExchangeCreateViewController: ExchangeCreateViewDelegate {
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

extension ExchangeCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.onChangeAmountFieldText()
        return true
    }
}

extension ExchangeCreateViewController: AddressSelectionDelegate {
    func getAssetType() -> LegacyAssetType {
        return LegacyAssetType(rawValue: -1)!
    }

    func didSelect(fromAccount account: Int32, assetType asset: LegacyAssetType) {
        delegate?.onChangeFrom(assetType: AssetType.from(legacyAssetType: asset))
    }

    func didSelect(toAccount account: Int32, assetType asset: LegacyAssetType) {
        delegate?.onChangeTo(assetType: AssetType.from(legacyAssetType: asset))
    }
}
