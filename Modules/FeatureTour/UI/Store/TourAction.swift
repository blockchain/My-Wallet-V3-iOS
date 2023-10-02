// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum TourAction {
    case createAccount
    case didChangeStep(TourState.Step)
    case restore
    case logIn
    case manualLogin
    case price(id: Price.ID, action: PriceAction)
    case priceListDidScroll(offset: CGFloat)
    case loadPrices
    case none
}
