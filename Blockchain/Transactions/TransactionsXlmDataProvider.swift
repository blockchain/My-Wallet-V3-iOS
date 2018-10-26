//
//  TransactionsXlmDataProvider.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsXlmDataProvider: SimpleListDataProvider {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = models else { return UITableViewCell() }

        if items.count > indexPath.row {
            let model = items[indexPath.row]
            return UITableViewCell()
        }

        if indexPath.row == items.count && isPaging {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        return UITableViewCell()
    }

    func cell() {
        let payment = StellarOperation.Payment(
            token: "op.token",
            identifier: "op.id",
            fromAccount: "op.from",
            toAccount: "op.to",
            direction: .credit,
            amount: "op.amount",
            transactionHash: "op.transactionHash",
            createdAt: Date()
        )

        let tx = Transaction()
    }
}
