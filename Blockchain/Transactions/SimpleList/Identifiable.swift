//
//  Identifiable.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol Identifiable {
    var identifier: String { get }
    func cellType() -> TransactionTableCell.Type
}
