//
//  ExchangeDetailContracts.swift
//  Blockchain
//
//  Created by kevinwu on 9/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeDetailInterface: class {
    func updateBackgroundColor(_ color: UIColor)
    func navigationBarVisibility(_ visibility: Visibility)
    func updateTitle(_ value: String)
    func loadingVisibility(_ visibility: Visibility, action: ExchangeDetailCoordinator.Action)
}

protocol ExchangeDetailInput: class {
    func viewLoaded()
    func sendOrderTapped()
}

protocol ExchangeDetailOutput: class {
    func conversionReceived()
    func orderSent()
}
