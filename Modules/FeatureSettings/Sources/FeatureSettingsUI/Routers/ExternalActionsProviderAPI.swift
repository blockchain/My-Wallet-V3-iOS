// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ExternalActionsProviderAPI {
    func logout()
    func exitToPinScreen()
    func logoutAndForgetWallet()
    func handleSupport()
    func handleSecureChannel()
}
