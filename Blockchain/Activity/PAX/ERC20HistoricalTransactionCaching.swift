//
//  ERC20HistoricalTransactionCaching.swift
//  Blockchain
//
//  Created by AlexM on 5/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ERC20Kit
import RxSwift

class ERC20HistoricalTransactionCaching<T: ERC20Token>: Caching {
    typealias Item = ERC20HistoricalTransaction<T>
    private var cache = Dictionary<String, Item>()
    
    func save(_ item: ERC20HistoricalTransaction<T>, key: String) {
        if let value = cache[key], value != item {
            cache[key] = item
        }
        
        if cache[key] == nil {
            cache[key] = item
        }
    }
    
    func itemWithKey(_ key: String) -> ERC20HistoricalTransaction<T>? {
        return cache[key]
    }
    
    // MARK: Rx
    
    func item(with key: String) -> Maybe<ERC20HistoricalTransaction<T>> {
        guard let value = cache[key] else { return Maybe.empty() }
        return Maybe.just(value)
    }
}
