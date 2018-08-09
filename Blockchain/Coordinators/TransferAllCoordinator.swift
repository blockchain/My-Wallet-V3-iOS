//
//  TransferAllCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Coordinator for the transfer all flow.
@objc class TransferAllCoordinator: NSObject, Coordinator {
    static let shared = TransferAllCoordinator()

    // class function declared so that the TransferAllCoordinator singleton can be accessed from obj-C
    @objc class func sharedInstance() -> TransferAllCoordinator {
        return TransferAllCoordinator.shared
    }

    private override init() {
        super.init()
        WalletManager.shared.transferAllDelegate = self
    }

    private var transferAllController: TransferAllFundsViewController?

    func start() {
        transferAllController = TransferAllFundsViewController()
        let navigationController = BCNavigationController(
            rootViewController: transferAllController,
            title: NSLocalizedString("Transfer All Funds",
                                     comment: "")
        )
        let tabViewController = AppCoordinator.shared.tabControllerManager.tabViewController
        tabViewController?.topMostViewController!.present(navigationController, animated: true, completion: nil)
    }

    @objc func start(withDelegate delegate: TransferAllPromptDelegate) {
        start()
        transferAllController?.delegate = delegate
    }

    @objc func startWithSendScreen() {
        transferAllController = nil
        AppCoordinator.shared.tabControllerManager.setupTransferAllFunds()
    }
}

extension TransferAllCoordinator: WalletTransferAllDelegate {
    func updateTransferAll(amount: NSNumber, fee: NSNumber, addressesUsed: NSArray) {
        if transferAllController != nil {
            transferAllController?.updateTransferAllAmount(amount, fee: fee, addressesUsed: addressesUsed as? [Any])
        } else {
            AppCoordinator.shared.tabControllerManager.updateTransferAllAmount(amount, fee: fee, addressesUsed: addressesUsed as? [Any])
        }
    }

    func showSummaryForTransferAll() {
        if transferAllController != nil {
            transferAllController?.showSummaryForTransferAll()
            LoadingViewPresenter.shared.hideBusyView()
        } else {
            AppCoordinator.shared.tabControllerManager.showSummaryForTransferAll()
        }
    }

    func sendDuringTransferAll(secondPassword: String?) {
        if transferAllController != nil {
            transferAllController?.sendDuringTransferAll(secondPassword)
        } else {
            AppCoordinator.shared.tabControllerManager.sendDuringTransferAll(secondPassword)
        }
    }

    func didErrorDuringTransferAll(error: String, secondPassword: String?) {
        AppCoordinator.shared.tabControllerManager.didErrorDuringTransferAll(error, secondPassword: secondPassword)
    }
}
