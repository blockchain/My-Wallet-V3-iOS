// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit
import WalletPayloadKit

final class NoOpLoginService: LoginServiceAPI {
    var authenticator: AnyPublisher<WalletPayloadKit.WalletAuthenticatorType, Never> {
        .empty()
    }

    func login(walletIdentifier: String) -> AnyPublisher<Void, FeatureAuthenticationDomain.LoginServiceError> {
        .just(())
    }

    func login(walletIdentifier: String, code: String) -> AnyPublisher<Void, FeatureAuthenticationDomain.LoginServiceError> {
        .just(())
    }
}
