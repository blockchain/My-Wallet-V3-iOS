//
//  SimpleListServiceAPI.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SimpleListServiceAPI {
    func fetchAllItems(output: SimpleListOutput?)
    func fetchDetails(for item: Identifiable, output: SimpleListOutput?)
    func refresh(output: SimpleListOutput?)
    func nextPageBefore(identifier: String)
    func cancel()
    func isExecuting() -> Bool
    func canPage() -> Bool
}
