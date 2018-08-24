//
//  ExchangeTradeCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeTradeCoordinator: NSObject {
    fileprivate weak var interface: ExchangeTradeInterface?

    init(interface: ExchangeTradeInterface) {
        self.interface = interface
        super.init()

        if let controller = interface as? HomebrewExchangeCreateViewController {
            controller.delegate = self
        }
    }
}

extension ExchangeTradeCoordinator: ExchangeTradeDelegate {
    func onContinueButtonTapped() {
        
    }
}
