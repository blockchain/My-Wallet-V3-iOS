//
//  PaxActivityDataProvider.swift
//  Blockchain
//
//  Created by AlexM on 5/20/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ERC20Kit

extension ERC20HistoricalTransaction: Identifiable {
    func cellType() -> TransactionTableCell.Type {
        return TransactionTableCell.self
    }
    
    var identifier: String {
        return transactionHash
    }
}

class PaxActivityDataProvider: SimpleListDataProvider {
    
    override func registerAllCellTypes() {
        guard let table = tableView else { return }
        let loadingCell = UINib(nibName: LoadingTableViewCell.identifier, bundle: nil)
        let transactionCell = UINib(nibName: TransactionTableCell.identifier, bundle: nil)
        table.register(loadingCell, forCellReuseIdentifier: LoadingTableViewCell.identifier)
        table.register(transactionCell, forCellReuseIdentifier: TransactionTableCell.identifier)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isPaging ? LoadingTableViewCell.height() : 64.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let loadingIdentifier = LoadingTableViewCell.identifier
        
        switch indexPath.section {
        case 0:
            guard let items = models else { return UITableViewCell() }
            
            if items.count > indexPath.row {
                guard let model = items[indexPath.row] as? ERC20HistoricalTransaction<PaxToken> else { return UITableViewCell() }
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: model.cellType().identifier,
                    for: indexPath
                ) as? TransactionTableCell else { return UITableViewCell() }
                /// This particular cell shouldn't have a separator.
                /// This is how we hide it.
                cell.separatorInset = UIEdgeInsets(
                    top: 0.0,
                    left: 0.0,
                    bottom: 0.0,
                    right: .greatestFiniteMagnitude
                )
                let viewModel = TransactionDetailViewModel(transaction: model)
                cell.configure(with: viewModel)
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            if indexPath.row == items.count && isPaging {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: loadingIdentifier,
                    for: indexPath
                ) as? LoadingTableViewCell else { return UITableViewCell() }
                
                /// This particular cell shouldn't have a separator.
                /// This is how we hide it.
                cell.separatorInset = UIEdgeInsets(
                    top: 0.0,
                    left: 0.0,
                    bottom: 0.0,
                    right: .greatestFiniteMagnitude
                )
                return cell
            }
            
        default:
            break
        }
        
        return UITableViewCell()
    }
}
