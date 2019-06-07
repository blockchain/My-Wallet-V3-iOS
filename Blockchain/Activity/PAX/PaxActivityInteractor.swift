//
//  PaxActivityInteractor.swift
//  Blockchain
//
//  Created by AlexM on 5/21/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class PaxActivityInteractor: SimpleListInteractor {
    
    init(with provider: PAXServiceProvider = PAXServiceProvider.shared) {
        super.init()
        service = PaxActivityServiceAPI(provider: provider)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func canPage() -> Bool {
        return service?.canPage() ?? false
    }
}
