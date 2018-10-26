//
//  TransactionTableCell+ViewModel.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// If TransactionTableCell is converted to Swift, it should implement
// these methods to allow configuration with a TransactionDetailViewModel
// instead of with a specific Transaction object.
extension TransactionTableCell {

    func configure(with viewModel: TransactionDetailViewModel) {
        setTxType("sent")
        setDateLabelText(viewModel.dateString)
        setButtonText(viewModel.amountString)
        setInfoType(TransactionInfoTypeDefault)
    }

    func showViewModelDetail(viewModel: TransactionDetailViewModel, viewController: UIViewController) {
        let detailViewController = TransactionDetailViewController()
        detailViewController.transactionModel = viewModel

        let navigationController = TransactionDetailNavigationController(rootViewController: detailViewController)
        navigationController.transactionHash = viewModel.myHash

        navigationController.modalTransitionStyle = .coverVertical

        viewController.present(navigationController, animated: true)
    }
}
