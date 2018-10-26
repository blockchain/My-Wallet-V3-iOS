//
//  TransactionsXlmInteractor.swift
//  Blockchain
//
//  Created by kevinwu on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class TransactionsXlmInteractor: SimpleListInteractor {

    required init() {
        super.init()
        service = StellarTransactionServiceAPI()
    }
}
