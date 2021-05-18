//
//  TabControllerManager+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ActivityUIKit
import BuySellUIKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RIBs
import ToolKit
import TransactionUIKit

final class TabControllerManager: NSObject {

    // MARK: - Properties

    @objc let tabViewController: TabViewController

    // MARK: - Private Properties

    private var activityNavigationController: UINavigationController!
    private var dashboardNavigationController: UINavigationController!
    private var receiveNavigationViewController: UINavigationController!
    private var sendViewController: UIViewController!
    private var sendP2ViewController: UIViewController!
    private var swapViewController: UIViewController!
    private var swapRouter: ViewableRouting!
    private var sendRouter: SendRootRouting!

    private var analyticsEventRecorder: AnalyticsEventRecording
    private let sendControllerManager: SendControllerManager
    private let sendReceiveCoordinator: SendReceiveCoordinator
    private let featureConfigurator: FeatureConfiguring
    private let internalFeatureFlag: InternalFeatureFlagServiceAPI

    init(sendControllerManager: SendControllerManager = resolve(),
         sendReceiveCoordinator: SendReceiveCoordinator = resolve(),
         analyticsEventRecorder: AnalyticsEventRecording = resolve(),
         featureConfigurator: FeatureConfiguring = resolve(),
         internalFeatureFlag: InternalFeatureFlagServiceAPI = resolve()) {
        self.sendControllerManager = sendControllerManager
        self.sendReceiveCoordinator = sendReceiveCoordinator
        self.analyticsEventRecorder = analyticsEventRecorder
        self.featureConfigurator = featureConfigurator
        self.internalFeatureFlag = internalFeatureFlag
        tabViewController = TabViewController.makeFromStoryboard()
        super.init()
        tabViewController.delegate = self
    }

    // MARK: - Show

    func showDashboard() {
        if dashboardNavigationController == nil {
            dashboardNavigationController = UINavigationController(rootViewController: DashboardViewController())
        }
        tabViewController.setActiveViewController(dashboardNavigationController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabDashboard)
    }

    @objc func showTransactions() {
        if activityNavigationController == nil {
            activityNavigationController = UINavigationController(rootViewController: ActivityScreenViewController())
        }
        tabViewController.setActiveViewController(activityNavigationController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabTransactions)
    }

    private func loadSwap() {
        guard swapViewController == nil else { return }
        guard swapRouter == nil else { return }
        
        func populateNewSwap() {
            let router = SwapRootBuilder().build()
            swapViewController = router.viewControllable.uiviewController
            swapRouter = router
            router.interactable.activate()
            router.load()
        }
        populateNewSwap()
    }

    func showSwap() {
        loadSwap()
        tabViewController.setActiveViewController(
            swapViewController,
            animated: true,
            index: Constants.Navigation.tabSwap
        )
    }
    
    private func loadSend() {
        switch internalFeatureFlag.isEnabled(.nonCustodialSendP2) {
        case true:
            guard sendP2ViewController == nil else { return }
            let router = SendRootBuilder().build()
            sendP2ViewController = router.viewControllable.uiviewController
            sendRouter = router
            router.interactable.activate()
            router.load()
        case false:
            guard sendViewController == nil else { return }
            sendViewController = sendReceiveCoordinator.builder.send()
        }
    }
    
    func send(from account: BlockchainAccount) {
        if sendRouter == nil {
            sendRouter = SendRootBuilder().build()
        }
        sendRouter.interactable.activate()
        sendRouter.load()
        sendRouter.routeToSend(sourceAccount: account as! CryptoAccount)
    }

    func showSend(cryptoCurrency: CryptoCurrency) {
        loadSend()
        switch internalFeatureFlag.isEnabled(.nonCustodialSendP2) {
        case true:
            tabViewController.setActiveViewController(
                sendP2ViewController,
                animated: true,
                index: Constants.Navigation.tabSend
            )
        case false:
            tabViewController.setActiveViewController(
                UINavigationController(rootViewController: sendViewController),
                animated: true,
                index: Constants.Navigation.tabSend
            )
        }
    }

    func showSend() {
        loadSend()
        switch internalFeatureFlag.isEnabled(.nonCustodialSendP2) {
        case true:
            tabViewController.setActiveViewController(
                sendP2ViewController,
                animated: true,
                index: Constants.Navigation.tabSend
            )
        case false:
            tabViewController.setActiveViewController(
                UINavigationController(rootViewController: sendViewController),
                animated: true,
                index: Constants.Navigation.tabSend
            )
        }
    }

    func showReceive() {
        if receiveNavigationViewController == nil {
            let receive = sendReceiveCoordinator.builder.receive()
            receiveNavigationViewController = UINavigationController(rootViewController: receive)
        }
        tabViewController.setActiveViewController(receiveNavigationViewController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabReceive)
    }

    // MARK: - SendControllerManager Redirections

    func reload() {
        sendControllerManager.reload()
    }

    func reloadAfterMultiAddressResponse() {
        sendControllerManager.reloadAfterMultiAddressResponse()
    }

    func hideSendAndReceiveKeyboards() {
        sendControllerManager.hideKeyboards()
    }

    func reloadSymbols() {
        sendControllerManager.reloadSymbols()
    }

    @objc func transferFundsToDefaultAccount(from address: String) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.transferFundsToDefaultAccount(from: address)
            }
        )
    }

    // MARK: Transfer All

    func setupTransferAllFunds() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.setupTransferAllFunds()
            }
        )
    }

    // MARK: BitPay

    func setupBitpayPayment(from url: URL) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.setupBitpayPayment(from: url)
            }
        )
    }

    func setupBitcoinPaymentFromURLHandler(with amount: String?, address: String) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.setupBitcoinPayment(amount: amount, address: address)
            }
        )
    }
}

// MARK: - WalletTransferAllDelegate

extension TabControllerManager: WalletTransferAllDelegate {
    func updateTransferAll(amount: NSNumber, fee: NSNumber, addressesUsed: [Any]) {
        sendControllerManager.updateTransferAll(amount: amount, fee: fee, addressesUsed: addressesUsed)
    }

    func showSummaryForTransferAll() {
        sendControllerManager.showSummaryForTransferAll()
    }

    func sendDuringTransferAll(secondPassword: String?) {
        sendControllerManager.sendDuringTransferAll(secondPassword: secondPassword)
    }

    func didErrorDuringTransferAll(error: String, secondPassword: String?) {
        sendControllerManager.didErrorDuringTransferAll(error: error, secondPassword: secondPassword)
    }
}

// MARK: - WalletTransactionDelegate

extension TabControllerManager: WalletTransactionDelegate {
    func onTransactionReceived() {
        SoundManager.shared.playBeep()
        NotificationCenter.default.post(Notification(name: Constants.NotificationKeys.transactionReceived))
    }

    func didPushTransaction() {
        let eventName: String
        switch sendControllerManager.bitcoinAddressSource {
        case .QR:
            eventName = "wallet_ios_tx_from_qr"
        case .URI:
            eventName = "wallet_ios_tx_from_uri"
        case .dropDown:
            eventName = "wallet_ios_tx_from_dropdown"
        case .paste:
            eventName = "wallet_ios_tx_from_paste"
        case .bitPay,
             .exchange,
             .none:
            return
        }

        guard let url = URL(string: "\(BlockchainAPI.shared.walletUrl)/event?name=\(eventName)") else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let session: URLSession = resolve()
        let dataTask = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {
                Logger.shared.debug("Error saving address input: \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }
}

// MARK: - WalletSendEtherDelegate

extension TabControllerManager: WalletSendEtherDelegate {
    func didGetEtherAddressWithSecondPassword() {
        // TODO: IOS-2193
    }
}

// MARK: - WalletSettingsDelegate

extension TabControllerManager: WalletSettingsDelegate {
    func didChangeLocalCurrency() {
        sendControllerManager.didChangeLocalCurrency()
    }
}

// MARK: - TabViewControllerDelegate

extension TabControllerManager: TabViewControllerDelegate {
    func tabViewController(_ tabViewController: TabViewController, viewDidAppear animated: Bool) {
        // NOOP
    }

    // MARK: - View Life Cycle

    func tabViewControllerViewDidLoad(_ tabViewController: TabViewController) {
        let walletManager = WalletManager.shared
        walletManager.settingsDelegate = self
        walletManager.sendBitcoinDelegate = self.sendControllerManager
        walletManager.sendEtherDelegate = self
        walletManager.transactionDelegate = self
    }

    func sendClicked() {
        showSend()
    }

    func receiveClicked() {
        showReceive()
    }

    func transactionsClicked() {
        analyticsEventRecorder.record(
             event: AnalyticsEvents.Transactions.transactionsTabItemClick
         )
        showTransactions()
    }

    func dashBoardClicked() {
        showDashboard()
    }

    func swapClicked() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Swap.swapTabItemClick
        )
        showSwap()
    }
}
