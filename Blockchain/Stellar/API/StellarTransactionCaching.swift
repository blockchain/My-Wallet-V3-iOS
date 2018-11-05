//
//  StellarTransactionCaching.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol Caching {
    associatedtype Item: Hashable
    func save(_ item: Item, key: String)
    func itemWithKey(_ key: String) -> Item?
}

class StellarTransactionCache: Caching {
    typealias Item = StellarOperation
    private var cache = Dictionary<String, Item>()
    
    func save(_ item: StellarOperation, key: String) {
        cache[key] = item
    }
    
    func itemWithKey(_ key: String) -> StellarOperation? {
        return cache[key]
    }
}
