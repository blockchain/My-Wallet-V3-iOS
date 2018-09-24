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
    func updateConfirmDetails(conversion: Conversion)

    // When live updates are being received, the ExchangeDetailCoordinator
    // fully reloads each collection view with new cells and doesn't have
    // a reference to the existing ones, so the most recent order
    // transaction must be saved to repopulate the fee field.
    var mostRecentOrderTransaction: OrderTransaction? { get set }

    // Live updates are still being received from the conversion socket,
    // so the last conversion should be used to create the transaction
    var mostRecentConversion: Conversion? { get set }
}

protocol ExchangeDetailInput: class {
    func viewLoaded()
    func sendOrderTapped()
}

protocol ExchangeDetailOutput: class {
    func received(conversion: Conversion)
    func orderSent()
}
