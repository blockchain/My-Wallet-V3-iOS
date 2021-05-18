//
//  SendControllerManager.swift
//  Blockchain
//
//  Created by Paulo on 20/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import TransactionKit
import TransactionUIKit

class SendControllerManager: NSObject {

    private lazy var ethereumRouter: SendRouter = SendRouter(asset: .ethereum)

    private(set) weak var sendBTC: SendBitcoinViewController?
    private(set) weak var sendBCH: SendBitcoinViewController?

    private let navigationRouter: NavigationRouterAPI

    init(navigationRouter: NavigationRouterAPI = NavigationRouter()) {
        self.navigationRouter = navigationRouter
    }

    func showSend(_ cryptoCurrency: CryptoCurrency) {
        let viewController = send(cryptoCurrency)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            self?.navigationRouter.present(viewController: viewController)
        }
    }
}

extension SendControllerManager: SendScreenProvider {

    private func createSendBTC() -> SendBitcoinViewController {
        let vc = SendBitcoinViewController.make(cryptoCurrency: .bitcoin)
        sendBTC = vc
        return vc
    }

    private func createSendBCH() -> SendBitcoinViewController {
        let vc = SendBitcoinViewController.make(cryptoCurrency: .bitcoinCash)
        sendBCH = vc
        return vc
    }

    func send(_ cryptoCurrency: CryptoCurrency) -> UIViewController {
        switch cryptoCurrency {
        case .aave,
             .algorand,
             .polkadot,
             .tether,
             .wDGLD,
             .yearnFinance:
            fatalError("\(cryptoCurrency.name) Not Supported by Legacy Send.")
        case .bitcoin:
            return BaseNavigationController(rootViewController: createSendBTC())
        case .bitcoinCash:
            return BaseNavigationController(rootViewController: createSendBCH())
        case .ethereum:
            let sendETH = ethereumRouter.sendViewController()
            return BaseNavigationController(rootViewController: sendETH)
        case .pax:
            let sendPAX = SendPaxViewController.make()
            return BaseNavigationController(rootViewController: sendPAX)
        case .stellar:
            let sendXLM = SendLumensViewController.make(with: .shared)
            return BaseNavigationController(rootViewController: sendXLM)
        }
    }
}

@objc extension SendControllerManager: WalletSendBitcoinDelegate {
    func didCheckForOverSpending(amount: NSNumber, fee: NSNumber) {
        sendBTC?.didCheck(forOverSpending: amount, fee: fee)
    }

    func didGetMaxFee(fee: NSNumber, amount: NSNumber, dust: NSNumber?, willConfirm: Bool) {
        sendBTC?.didGetMaxFee(fee, amount: amount, dust: dust, willConfirm: willConfirm)
    }

    func didGetFee(fee: NSNumber, dust: NSNumber?, txSize: NSNumber) {
        sendBTC?.didGetFee(fee, dust: dust, txSize: txSize)
    }

    func didChangeSatoshiPerByte(sweepAmount: NSNumber, fee: NSNumber, dust: NSNumber?, updateType: FeeUpdateType) {
        sendBTC?.didChangeSatoshiPerByte(sweepAmount, fee: fee, dust: dust, updateType: updateType)
    }

    func enableSendPaymentButtons() {
        sendBTC?.enablePaymentButtons()
    }

    func updateSendBalance(balance: NSNumber, fees: [AnyHashable : Any]) {
        sendBTC?.updateSendBalance(balance, fees: fees)
    }

    func didUpdateTotalAvailableBTC(sweepAmount: NSNumber, finalFee: NSNumber) {
        sendBTC?.didUpdateTotalAvailable(sweepAmount, finalFee: finalFee)
    }

    func didUpdateTotalAvailableBCH(sweepAmount: NSNumber, finalFee: NSNumber) {
        sendBCH?.didUpdateTotalAvailable(sweepAmount, finalFee: finalFee)
    }

    /// This is called when a payment `UnspentOutputs` JS API call (https://blockchain.info/unspent) returns with a `notice` field.
    /// my-wallet.js, line 31005, function getUnspentCoins(addressList, notify)
    func didReceivePaymentNotice(notice: String?) {
        guard let notice = notice, !notice.isEmpty else {
            return
        }
        guard sendBTC?.isViewLoaded == true || sendBCH?.isViewLoaded == true else {
            return
        }
        guard !LoadingViewPresenter.shared.isVisible else {
            return
        }
        guard !AuthenticationCoordinator.shared.isDisplayingLoginAuthenticationFlow else {
            return
        }
        AlertViewPresenter.shared.standardNotify(title: LocalizationConstantsObjcBridge.information(), message: notice)
    }

    func didErrorWhileBuildingPayment(error: String) {
        guard sendBTC?.isViewLoaded == true else { return }

        AlertViewPresenter.shared.standardError(
            title: LocalizationConstantsObjcBridge.error(),
            message: error,
            in: sendBTC,
            handler: nil
        )
    }
}

@objc extension SendControllerManager: WalletTransferAllDelegate {
    func updateTransferAll(amount: NSNumber, fee: NSNumber, addressesUsed: [Any]) {
        sendBTC?.updateTransferAllAmount(amount, fee: fee, addressesUsed: addressesUsed)
    }

    func showSummaryForTransferAll() {
        sendBTC?.showSummaryForTransferAll()
    }

    func sendDuringTransferAll(secondPassword: String?) {
        sendBTC?.sendDuringTransferAll(secondPassword)
    }

    func didErrorDuringTransferAll(error: String, secondPassword: String?) {
        sendBTC?.didErrorDuringTransferAll(error, secondPassword: secondPassword)
    }
}

@objc extension SendControllerManager {
    var bitcoinAddressSource: DestinationAddressSource {
        sendBTC?.addressSource ?? .none
    }

    func transferFundsToDefaultAccount(from address: String) {
        if let sendBTC = self.sendBTC {
            sendBTC.transferFundsToDefaultAccount(fromAddress: address)
        } else {
            let sendBTC = send(.bitcoin)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?.navigationRouter.present(viewController: sendBTC)
                self?.sendBTC?.transferFundsToDefaultAccount(fromAddress: address)
            }
        }
    }

    func didChangeLocalCurrency() {
        sendBTC?.reloadFeeAmountLabel()
    }

    func reload() {
        sendBTC?.reload()
        sendBCH?.reload()
    }

    func hideKeyboards() {
        sendBTC?.hideKeyboardForced()
        sendBTC?.enablePaymentButtons()
    }

    func reloadSymbols() {
        sendBTC?.reloadSymbols()
        sendBCH?.reloadSymbols()
    }

    func reloadAfterMultiAddressResponse() {
        sendBTC?.reloadAfterMultiAddressResponse()
        sendBCH?.reloadAfterMultiAddressResponse()
    }

    func setupTransferAllFunds() {
        if let sendBTC = self.sendBTC {
            sendBTC.setupTransferAll()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                guard let self = self else { return }
                self.navigationRouter.present(viewController: self.send(.bitcoin))
                self.sendBTC?.setupTransferAll()
                self.sendBTC?.reload()
            }
        }
    }

    func setupBitpayPayment(from url: URL) {
        if let sendBTC = self.sendBTC {
            sendBTC.setAmountStringFromBitPay(url)
        } else {
            let sendBTC = send(.bitcoin)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?.navigationRouter.present(viewController: sendBTC)
                self?.sendBTC?.setAmountStringFromBitPay(url)
            }
        }
    }

    func setupBitcoinPayment(amount: String?, address: String) {
        if let sendBTC = self.sendBTC {
            sendBTC.setAmountStringFromUrlHandler(amount, withToAddress: address)
        } else {
            let sendBTC = send(.bitcoin)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                self?.navigationRouter.present(viewController: sendBTC)
                self?.sendBTC?.setAmountStringFromUrlHandler(amount, withToAddress: address)
                self?.sendBTC?.reload()
            }
        }
    }
}
