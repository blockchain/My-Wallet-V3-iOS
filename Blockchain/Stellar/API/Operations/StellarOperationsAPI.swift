//
//  StellarHistoryAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift

protocol StellarOperationsAPI {
    typealias AccountID = String
    typealias PageToken = String
    
    var operations: Observable<[StellarOperation]> { get }
    func isStreaming() -> Bool
    func end()
    func clear()
}
