//
//  CellModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum CellModel {
    case plain(String)
    case textEntry(TextEntry)
}

extension CellModel {

    func cellType() -> BaseTableViewCell.Type {
        switch self {
        case .plain:
            return PlainCell.self
        case .textEntry:
            return TextEntryCell.self
        }
    }

    func heightForProposed(width: CGFloat) -> CGFloat {
        return cellType().heightForProposedWidth(
            width,
            model: self
        )
    }
}
