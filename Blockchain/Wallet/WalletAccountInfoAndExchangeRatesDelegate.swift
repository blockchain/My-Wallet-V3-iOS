// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Temporary protocol to use in place of a completion handler that would be passed into getAccountInfoAndExchangeRates()
@objc protocol WalletAccountInfoAndExchangeRatesDelegate: AnyObject {

    /// Method invoked after getting account info and exchange rates on startup
    func didGetAccountInfoAndExchangeRates()
}
