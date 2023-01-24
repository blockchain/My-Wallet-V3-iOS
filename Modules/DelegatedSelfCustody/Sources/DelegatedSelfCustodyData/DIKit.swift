// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import DIKit
import NetworkKit

extension DependencyContainer {

    // MARK: - DelegatedSelfCustodyData Module

    public static var delegatedSelfCustodyData = module {

        factory {
            Client(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            )
        }

        factory { () -> AccountDataClientAPI in
            let client: Client = DIKit.resolve()
            return client as AccountDataClientAPI
        }

        factory { () -> SubscriptionsClientAPI in
            let client: Client = DIKit.resolve()
            return client as SubscriptionsClientAPI
        }

        factory { () -> AuthenticationClientAPI in
            let client: Client = DIKit.resolve()
            return client as AuthenticationClientAPI
        }

        factory { () -> TransactionsClientAPI in
            let client: Client = DIKit.resolve()
            return client as TransactionsClientAPI
        }

        single { () -> DelegatedCustodyBalanceRepositoryAPI in
            BalanceRepository(
                client: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve()
            )
        }

        factory {
            AssetSupportService(
                app: DIKit.resolve()
            )
        }

        single {
            AccountRepository(
                assetSupportService: DIKit.resolve(),
                derivationService: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve()
            )
        }

        factory { () -> AccountRepositoryAPI in
            let service: AccountRepository = DIKit.resolve()
            return service as AccountRepositoryAPI
        }

        factory { () -> DelegatedCustodyAccountRepositoryAPI in
            let service: AccountRepository = DIKit.resolve()
            return service as DelegatedCustodyAccountRepositoryAPI
        }

        factory { () -> DelegatedCustodyAuthenticationDataRepositoryAPI in
            AuthenticationDataRepository(
                guidService: DIKit.resolve(),
                sharedKeyService: DIKit.resolve()
            )
        }

        factory { () -> DelegatedCustodySubscriptionsServiceAPI in
            SubscriptionsService(
                accountRepository: DIKit.resolve(),
                authClient: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve(),
                subscriptionsClient: DIKit.resolve(),
                subscriptionsStateService: DIKit.resolve()
            )
        }

        factory { () -> SubscriptionsStateServiceAPI in
            SubscriptionsStateService(
                app: DIKit.resolve()
            )
        }

        factory { () -> DelegatedCustodyTransactionServiceAPI in
            TransactionService(
                client: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve(),
                signingService: DIKit.resolve()
            )
        }

        single { () -> DelegatedCustodyAddressesRepositoryAPI in
            AddressesRepository(
                client: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve()
            )
        }

        single { () -> DelegatedCustodyActivityRepositoryAPI in
            ActivityRepository(
                client: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve()
            )
        }
    }
}
