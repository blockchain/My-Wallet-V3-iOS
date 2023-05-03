// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions
import Foundation
import OptionalSubscripts

extension App {

    public static var preview: AppProtocol = debug()
 
#if DEBUG
    public static var test: App.Test { App.Test() }
#endif

    /// Creates a mocked AppProtocol instance.
    public static func debug(
        preferences: Preferences = Mock.Preferences(),
        remoteConfiguration: some RemoteConfiguration_p = Mock.RemoteConfiguration(),
        session: URLSessionProtocol = URLSession.test,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.test.eraseToAnyScheduler()
    ) -> AppProtocol {
        App(
            state: with(Session.State([:], preferences: preferences)) { state in
                state.data.keychain = (
                    user: Mock.Keychain(queryProvider: state.data.keychainAccount.user),
                    shared: Mock.Keychain(queryProvider: state.data.keychainAccount.shared)
                )
            },
            remoteConfiguration: Session.RemoteConfiguration(
                remote: remoteConfiguration,
                session: session,
                preferences: preferences,
                scheduler: scheduler
            )
        )
    }
}

extension AppProtocol {
    public func withPreviewData(
        fiatCurrency: String = "USD"
    ) -> AppProtocol {
        setup { app in
            app.state.set(blockchain.user.id, to: "User")
            app.state.set(blockchain.user.currency.preferred.fiat.trading.currency, to: fiatCurrency)
            app.state.set(blockchain.api.nabu.gateway.price.crypto.fiat.id, to: fiatCurrency)
            try await app.register(
                napi: blockchain.api.nabu.gateway.price,
                domain: blockchain.api.nabu.gateway.price.crypto.fiat,
                repository: { tag -> AnyJSON in
                    do {
                        return try [
                            "currency": tag.indices[blockchain.api.nabu.gateway.price.crypto.id].decode(String.self),
                            "quote": [
                                "value": [
                                    "amount": Int.random(in: 200...2000000).description,
                                    "currency": tag.indices[blockchain.api.nabu.gateway.price.crypto.fiat.id].decode(String.self)
                                ] as [String: Any]
                            ]
                        ]
                    } catch {
                        return .empty
                    }
                }
            )
        }
    }
}
