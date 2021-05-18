//
//  Wallet.swift
//  Blockchain
//
//  Created by Paulo on 16/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit
import PlatformKit
import PlatformUIKit
import RxSwift
import WalletPayloadKit

extension Wallet {
    private enum WalletJavaScriptError: Error {
        case typeError
    }

    @objc func logJavaScriptTypeError(_ message: String, stack: String?) {
        let messageRecorder: MessageRecording = resolve()
        let errorRecorder: ErrorRecording = resolve()
        messageRecorder.record("JS Stack: \(stack ?? "not available")")
        messageRecorder.record("JS Error: \(message)")
        errorRecorder.error(WalletJavaScriptError.typeError)
    }

    /// Updates an account label.
    /// - Parameters:
    ///   - label: The new account name.
    ///   - cryptoCurrency: The CryptoCurrency of the account you want to update.
    ///   - index: The derivation index of the account you want to update.
    func updateAccountLabel(
        _ cryptoCurrency: CryptoCurrency,
        index: Int,
        label: String
    ) -> Completable {
        Completable.create(weak: self) { (self, observer) -> Disposable in
            self.updateLabel(label, for: cryptoCurrency, index: index)
            observer(.completed)
            return Disposables.create()
        }
        .subscribeOn(MainScheduler.asyncInstance)
    }

    /// Updates an account label.
    /// - Parameters:
    ///   - label: The new account name.
    ///   - cryptoCurrency: The CryptoCurrency of the account you want to update.
    ///   - index: The derivation index of the account you want to update.
    private func updateLabel(_ label: String, for cryptoCurrency: CryptoCurrency, index: Int) {
        guard isInitialized() else {
            return
        }
        switch cryptoCurrency {
        case .bitcoin:
            isSyncing = true
            _ = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.setLabelForAccount(\(index), \"\(label)\")")
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didSetLabelForAccount),
                                                   name: Constants.NotificationKeys.backupSuccess,
                                                   object: nil)
        case .bitcoinCash:
            _ = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.bch.setLabelForAccount(\(index), \"\(label)\")")
            getHistory()
        case .stellar:
            _ = context.evaluateScriptCheckIsOnMainQueue("MyWallet.wallet.xlm.accounts[\(index)].label = \"\(label)\"")
            getHistory()
        case .ethereum:
            _ = context.evaluateScriptCheckIsOnMainQueue("MyWallet.wallet.eth.accounts[\(index)].label = \"\(label)\"")
            getHistory()
        case .aave,
             .algorand,
             .pax,
             .polkadot,
             .tether,
             .wDGLD,
             .yearnFinance:
            impossible()
        }
    }

    @objc func setLabelForAccount(_ index: Int, label: String, assetType: LegacyAssetType) {
        guard Reachability.hasInternetConnection() else {
            AlertViewPresenter.shared.internetConnection()
            return
        }
        let cryptoCurrency = CryptoCurrency(legacyAssetType: assetType)
        updateLabel(label, for: cryptoCurrency, index: index)
    }

    @objc func didSetLabelForAccount() {
        NotificationCenter.default.removeObserver(self,
                                                  name: Constants.NotificationKeys.backupSuccess,
                                                  object: nil)
        getHistory()
    }
}

extension Wallet: WalletUpgradingAPI {  }
