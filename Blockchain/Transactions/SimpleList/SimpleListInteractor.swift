//
//  SimpleListInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 10/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class SimpleListInteractor: NSObject, SimpleListInput {
    // Cannot be fileprivate because it must be accessible by subclass
    var service: SimpleListServiceAPI?

    weak var output: SimpleListOutput?

    // Called by SimpleListViewController factory method
    required override init() {
        super.init()
    }

    init(listService: SimpleListServiceAPI) {
        self.service = listService
    }

    func fetchAllItems() {
        service?.fetchAllItems(output: output)
    }

    func refresh() {
        service?.refresh(output: output)
    }

    func canPage() -> Bool {
        return false
    }

    func selected(_ item: Identifiable) {
        guard service?.isExecuting() == false else { return }
        service?.fetchDetails(for: item, output: output)
    }

    func nextPageBefore(identifier: String) {
        service?.nextPageBefore(identifier: identifier, output: output)
    }

    func cancel() {
        service?.cancel()
    }
}
