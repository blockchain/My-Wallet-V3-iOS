//
//  BuySellCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 6/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class BuySellCoordinator: NSObject, Coordinator {
    static let shared = BuySellCoordinator()

    @objc private(set) var buyBitcoinViewController: BuyBitcoinViewController?
    private let walletManager: WalletManager

    // class function declared so that the BuySellCoordinator singleton can be accessed from obj-C
    @objc class func sharedInstance() -> BuySellCoordinator {
        return BuySellCoordinator.shared
    }

    private init(walletManager: WalletManager = WalletManager.shared) {
        self.walletManager = walletManager
        super.init()
        self.walletManager.buySellDelegate = self
    }

    func start() {
        NetworkManager.shared.getWalletOptions(withCompletion: { response in
            let error = "Error with wallet options response when starting buy sell webview"
            guard let response = response else {
                print(error)
                return
            }
            guard let mobile = response[Constants.WalletOptionsKeys.mobile] as? [String: String] else {
                print(error)
                return
            }
            guard let rootURL = mobile[Constants.WalletOptionsKeys.walletRoot] else {
                print(error)
                return
            }
            self.initializeWebView(rootURL: rootURL)
        }, error: { _ in
            print("Error getting wallet options to start buy sell webview")
        })
    }

    private func initializeWebView(rootURL: String?) {
        buyBitcoinViewController = BuyBitcoinViewController(rootURL: rootURL)
    }

    @objc func showBuyBitcoinView() {
        guard let buyBitcoinViewController = buyBitcoinViewController else {
            print("buyBitcoinViewController not yet initialized")
            return
        }

        // TODO convert this dictionary into a model
        guard let loginDataDict = walletManager.wallet.executeJSSynchronous(
            "MyWalletPhone.getWebViewLoginData()"
            ).toDictionary() else {
                print("loginData from wallet is empty")
                return
        }

        guard let walletJson = loginDataDict["walletJson"] as? String else {
            print("walletJson is nil")
            return
        }

        guard let externalJson = loginDataDict["externalJson"] is NSNull ? "" : loginDataDict["externalJson"] as? String else {
            print("externalJson is nil")
            return
        }

        guard let magicHash = loginDataDict["magicHash"] is NSNull ? "" : loginDataDict["magicHash"] as? String else {
            print("magicHash is nil")
            return
        }

        buyBitcoinViewController.login(
            withJson: walletJson,
            externalJson: externalJson,
            magicHash: magicHash,
            password: walletManager.wallet.password
        )
        buyBitcoinViewController.delegate = walletManager.wallet // TODO fix this

        guard let navigationController = BuyBitcoinNavigationController(
            rootViewController: buyBitcoinViewController,
            title: LocalizationConstants.SideMenu.buySellBitcoin
            ) else {
                return
        }

        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            navigationController,
            animated: true
        )
    }
}

extension BuySellCoordinator: WalletBuySellDelegate {
    func didCompleteTrade(trade: Trade) {
        let actions = [UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil),
                       UIAlertAction(title: LocalizationConstants.BuySell.viewDetails, style: .default, handler: { _ in
                        AppCoordinator.shared.tabControllerManager.showTransactionDetail(forHash: trade.hash)
                       })]
        AlertViewPresenter.shared.standardNotify(message: String(format: LocalizationConstants.BuySell.tradeCompletedDetailArg, trade.date),
                                                 title: LocalizationConstants.BuySell.tradeCompleted,
                                                 actions: actions)
    }

    func showCompletedTrade(tradeHash: String) {
        AppCoordinator.shared.closeSideMenu()
        AppCoordinator.shared.tabControllerManager.showTransactions(animated: true)
        AppCoordinator.shared.tabControllerManager.showTransactionDetail(forHash: tradeHash)
    }
}
