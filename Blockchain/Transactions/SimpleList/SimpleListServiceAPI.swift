//
//  SimpleListServiceAPI.swift
//  Blockchain
//
//  Created by kevinwu on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// [TICKET]: IOS-2209: Remove "Simple" UITableView API and
// replace with a Paging and Socket alternative in PlatformUIKit
// Do not continue to use this API.
protocol SimpleListServiceAPI {
    func fetchAllItems(output: SimpleListOutput?)
    func fetchDetails(for item: Identifiable, output: SimpleListOutput?)
    func refresh(output: SimpleListOutput?)
    func nextPageBefore(identifier: String, output: SimpleListOutput?)
    func cancel()
    func isExecuting() -> Bool
    func canPage() -> Bool
}
