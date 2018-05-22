//
//  TransferAllCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Coordinator for the transfer all flow.
class TransferAllCoordinator: Coordinator {
    static let shared = TransferAllCoordinator()

    private init() {
        WalletManager.shared.transferAllDelegate = self
    }

    weak var transferDelegate: TransferAllPromptDelegate?
    var transferAllController: TransferAllFundsViewController?

    func start() {
        transferAllController = TransferAllFundsViewController()
        let navigationController = BCNavigationController(
            rootViewController: transferAllController,
            title: NSLocalizedString("Transfer All Funds",
                                     comment: "")
        )
        let tabViewController = AppCoordinator.shared.tabControllerManager.tabViewController
        tabViewController?.topMostViewController!.present(navigationController!, animated: true, completion: nil)
    }
}

extension TransferAllCoordinator: WalletTransferAllDelegate {
    func updateTransferAll(amount: NSNumber, fee: NSNumber, addressesUsed: NSArray) {
        if transferAllController != nil {
            transferAllController?.updateTransferAllAmount(amount, fee: fee, addressesUsed: addressesUsed as! [Any])
        } else {
            AppCoordinator.shared.tabControllerManager.updateTransferAllAmount(amount, fee: fee, addressesUsed: addressesUsed as! [Any])
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
