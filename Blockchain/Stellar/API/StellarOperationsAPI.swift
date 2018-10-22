//
//  StellarHistoryAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk

protocol StellarOperationsAPI {
    typealias AccountID = String
    typealias PageToken = String
    typealias Completion = ((Result<[StellarOperation]>) -> Void)
    
    var canPage: Bool { get set }

    func operations(from accountID: AccountID, token: PageToken?, completion: @escaping Completion)
    func isExecuting() -> Bool
    func cancel()
}
