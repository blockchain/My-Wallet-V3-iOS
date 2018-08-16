//
//  FromToButtonCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 8/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class FromToButtonCoordinator: NSObject {
    private let wallet: Wallet
    private let navigationController: BCNavigationController
    private weak var addressSelectionDelegate: AddressSelectionDelegate?

    @objc init(
        wallet: Wallet = WalletManager.shared.wallet,
        navigationController: BCNavigationController,
        addressSelectionDelegate: AddressSelectionDelegate
    ) {
        self.wallet = wallet
        self.navigationController = navigationController
        self.addressSelectionDelegate = addressSelectionDelegate
    }

    fileprivate func selectAccount(selectMode: SelectMode) {
        guard let selectorView = BCAddressSelectionView(wallet: wallet, selectMode: selectMode, delegate: addressSelectionDelegate) else {
            Logger.shared.error("Couldn't create BCAddressSelectionView")
            return
        }
        selectorView.frame = UIView.rootViewSafeAreaFrame(navigationBar: true, tabBar: false, assetSelector: false)

        let viewController = UIViewController()
        viewController.automaticallyAdjustsScrollViewInsets = false
        viewController.view.addSubview(selectorView)
        self.navigationController.pushViewController(viewController, animated: true)
        
        switch selectMode {
        case SelectModeExchangeAccountTo: self.navigationController.headerTitle = LocalizationConstants.Exchange.to
        case SelectModeExchangeAccountFrom: self.navigationController.headerTitle = LocalizationConstants.Exchange.from
        default: Logger.shared.warning("Unsupported address select mode")
        }
    }
}

@objc extension FromToButtonCoordinator: FromToButtonDelegate {
    func fromButtonClicked() {
        selectAccount(selectMode: SelectModeExchangeAccountFrom)
    }
    
    func toButtonClicked() {
        selectAccount(selectMode: SelectModeExchangeAccountTo)
    }
}
