//
//  TransactionsXlmViewController.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsXlmViewController: SimpleTransactionsViewController {
    @objc class func make() -> TransactionsXlmViewController {
        let controller = SimpleListViewController.make(
            with: TransactionsXlmViewController.self,
            dataProvider: TransactionsXlmDataProvider.self,
            presenter: TransactionsXlmPresenter.self,
            interactor: TransactionsXlmInteractor.self
        )
        return controller
    }
}
