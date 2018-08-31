//
//  ListPresentationUpdate.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

enum ListPresentationUpdate<T: Equatable> {
    typealias Deleted = IndexPath
    typealias Inserted = IndexPath
    
    case insert(IndexPath, T)
    case delete(IndexPath)
    case move(Deleted, Inserted, T)
    case update(IndexPath, T)
}
