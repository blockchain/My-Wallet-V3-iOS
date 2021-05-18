//
//  TabViewController+SimpleBuy.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension TabViewController {
    func showCashIdentityVerificatonController(_ controller: CashIdentityVerificationViewController) {
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        controller.isModalInPresentation = true
        present(controller, animated: true, completion: nil)
    }
}
