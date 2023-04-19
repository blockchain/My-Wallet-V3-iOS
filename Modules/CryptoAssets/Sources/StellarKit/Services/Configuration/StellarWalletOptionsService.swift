// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

protocol StellarWalletOptionsBridgeAPI: AnyObject {
    var stellarConfigurationDomain: AnyPublisher<String?, Never> { get }
}

final class StellarWalletOptionsService: StellarWalletOptionsBridgeAPI {

    private let walletOptionsService: WalletOptionsAPI

    init(walletOptions: WalletOptionsAPI) {
        self.walletOptionsService = walletOptions
    }

    var stellarConfigurationDomain: AnyPublisher<String?, Never> {
        walletOptionsService
            .walletOptions
            .map(\.domains?.stellarHorizon)
            .asPublisher()
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
