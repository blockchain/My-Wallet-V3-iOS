// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import Foundation
import WalletConnectSwift
import Web3Wallet

/// Routes a WalletConnect URI to the appropriate service,
///
/// Once the v2 migration has completed all v1 related services and models would be removed
///
public final class WalletConnectVersionRouter {

    enum MyError: Error {
        case featureNotEnabled
        case unableToParseURI
        case versionNotSupported
    }

    let app: AppProtocol
    let v1Service: WalletConnectServiceAPI
    let v2Service: WalletConnectServiceV2API

    init(
        app: AppProtocol,
        v1Service: WalletConnectServiceAPI,
        v2Service: WalletConnectServiceV2API
    ) {
        self.app = app
        self.v1Service = v1Service
        self.v2Service = v2Service
    }

    @discardableResult
    public func pair(uri: String) async throws -> Bool {
        guard let isEnabled: Bool = try await app.get(blockchain.app.configuration.wallet.connect.is.enabled), isEnabled else {
            app.post(error: MyError.featureNotEnabled)
            return false
        }
        if WCURL(uri).isNotNil {
            v1Service.connect(uri)
            return true
        } else if let uri = WalletConnectURI(string: uri.removingPercentEncoding ?? uri) {
            try await v2Service.pair(uri: uri)
            return true
        } else {
            app.post(error: MyError.unableToParseURI)
        }
        return false
    }
}
