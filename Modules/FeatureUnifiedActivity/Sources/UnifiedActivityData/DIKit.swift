// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import DIKit
import NetworkKit
import UnifiedActivityDomain

extension DependencyContainer {

    // MARK: - DelegatedSelfCustodyData Module

    public static var unifiedActivityData = module {

        factory { LocaleIdentifierService() as LocaleIdentifierServiceAPI }

        single { () -> UnifiedActivityServiceAPI in
            let logger: NetworkDebugLogger = DIKit.resolve()
            let service = WebSocketService(
                consoleLogger: nil,
                networkDebugLogger: logger
            )
            return UnifiedActivityService(
                webSocketService: service,
                requestBuilder: DIKit.resolve(tag: DIKitContext.websocket),
                authenticationDataRepository: DIKit.resolve(),
                fiatCurrencyServiceAPI: DIKit.resolve(),
                localeIdentifierService: DIKit.resolve()
            )
        }

        single { () -> UnifiedActivityDetailsServiceAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve()
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.wallet)

            return UnifiedActivityDetailsService(
                requestBuilder: builder,
                networkAdapter: adapter,
                authenticationDataRepository: DIKit.resolve(),
                fiatCurrencyServiceAPI: DIKit.resolve(),
                localeIdentifierService: DIKit.resolve()
            )
        }

        single { () -> UnifiedActivityPersistenceServiceAPI in
            UnifiedActivityPersistenceService(
                appDatabase: DIKit.resolve(),
                service: DIKit.resolve(),
                configuration: .onLogout(),
                notificationCenter: .default,
                app: DIKit.resolve()
            )
        }

        single { () -> UnifiedActivityRepositoryAPI in
            UnifiedActivityRepository(
                appDatabase: DIKit.resolve(),
                allEntityRequest: ActivityEntityRequest(stateFilter: .all),
                pendingEntityRequest: ActivityEntityRequest(stateFilter: .pendingAndConfirming)
            )
        }

        single { () -> AppDatabaseAPI in
            AppDatabase.makeShared() as AppDatabaseAPI
        }
    }
}
