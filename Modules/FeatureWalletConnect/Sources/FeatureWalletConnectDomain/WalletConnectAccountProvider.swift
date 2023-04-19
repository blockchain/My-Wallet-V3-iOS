// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import Foundation
import MoneyKit
import PlatformKit

public protocol WalletConnectAccountProviderAPI {
    func defaultAccount(network: EVMNetwork) -> AnyPublisher<SingleAccount, CryptoAssetError>
}

final class WalletConnectAccountProvider {

    private let coincore: CoincoreAPI

    init(coincore: CoincoreAPI = resolve()) {
        self.coincore = coincore
    }
}

extension WalletConnectAccountProvider: WalletConnectAccountProviderAPI {
    func defaultAccount(network: EVMNetwork) -> AnyPublisher<SingleAccount, CryptoAssetError> {
        coincore[network.nativeAsset]?.defaultAccount ?? .failure(.noAsset)
    }
}

extension WalletConnectAccountProvider: WalletConnectPublicKeyProviderAPI {
    func publicKey(network: EVMNetwork) -> AnyPublisher<String, Error> {
        defaultAccount(network: network)
            .eraseError()
            .flatMap { account -> AnyPublisher<String, Error> in
                account.receiveAddress
                    .map(\.address)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
