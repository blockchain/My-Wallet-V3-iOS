// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CryptoSwift
import DelegatedSelfCustodyDomain
import Foundation
import Localization

final class SubscriptionsService: DelegatedCustodySubscriptionsServiceAPI {

    private let accountRepository: AccountRepositoryAPI
    private let authClient: AuthenticationClientAPI
    private let authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI
    private let subscriptionsClient: SubscriptionsClientAPI
    private let subscriptionsStateService: SubscriptionsStateServiceAPI

    init(
        accountRepository: AccountRepositoryAPI,
        authClient: AuthenticationClientAPI,
        authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI,
        subscriptionsClient: SubscriptionsClientAPI,
        subscriptionsStateService: SubscriptionsStateServiceAPI
    ) {
        self.accountRepository = accountRepository
        self.authClient = authClient
        self.authenticationDataRepository = authenticationDataRepository
        self.subscriptionsClient = subscriptionsClient
        self.subscriptionsStateService = subscriptionsStateService
    }

    func subscribe() -> AnyPublisher<Void, Error> {
        accounts
            .flatMap { [authenticate, subscriptionsStateService, subscribeAndRecord] accounts -> AnyPublisher<Void, Error> in
                subscriptionsStateService.isSubscribed(to: accounts)
                    .flatMap { isSubscribed -> AnyPublisher<Void, Error> in
                        guard !isSubscribed else {
                            return .just(())
                        }
                        return authenticate
                            .flatMap { _ -> AnyPublisher<Void, Error> in
                                subscribeAndRecord(accounts)
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func subscribeToNonDSCAccounts(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Error> {
        subscriptionsStateService.isSubscribed(to: accounts)
            .flatMap { [subscribeAndRecord] isSubscribed -> AnyPublisher<Void, Error> in
                guard !isSubscribed else {
                    return .just(())
                }
                return subscribeAndRecord(accounts)
            }
            .eraseToAnyPublisher()
    }

    private var authenticate: AnyPublisher<Void, Error> {
        authenticationDataRepository.initialAuthenticationData
            .eraseError()
            .flatMap { [authClient] authenticationData -> AnyPublisher<Void, Error> in
                authClient.auth(
                    guid: authenticationData.guid,
                    sharedKeyHash: authenticationData.sharedKeyHash
                )
                .eraseError()
            }
            .eraseToAnyPublisher()
    }

    /// Subscribe to a collection of SubscriptionEntry.
    private func subscribeAndRecord(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Error> {
        authenticationDataRepository.authenticationData.eraseError()
            .flatMap { [subscriptionsClient] authenticationData -> AnyPublisher<Void, Error> in
                subscriptionsClient.subscribe(
                    guidHash: authenticationData.guidHash,
                    sharedKeyHash: authenticationData.sharedKeyHash,
                    subscriptions: accounts
                )
                .eraseError()
            }
            .flatMap { [subscriptionsStateService] _ -> AnyPublisher<Void, Error> in
                subscriptionsStateService
                    .recordSubscription(accounts: accounts)
                    .eraseError()
            }
            .eraseToAnyPublisher()
    }

    /// SubscriptionEntry of all DSC accounts.
    private var accounts: AnyPublisher<[SubscriptionEntry], Error> {
        accountRepository
            .accounts
            .map { accounts -> [SubscriptionEntry] in
                accounts.map { account -> SubscriptionEntry in
                    SubscriptionEntry(
                        account: .init(index: 0, name: LocalizationConstants.Account.myWallet),
                        currency: account.coin.code,
                        pubKeys: [
                            .init(pubKey: account.publicKey.toHexString(), style: account.style, descriptor: 0)
                        ]
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
