//
//  ExchangeListAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias ExchangeListCompletion = (([ExchangeTradeCellModel]?, Error?) -> Void)

protocol ExchangeListAPI {
    func fetchTransactions(with completion: @escaping ExchangeListCompletion)
}
