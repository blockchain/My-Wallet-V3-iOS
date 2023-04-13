// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Foundation
import MoneyKit
import PlatformKit
import RxSwift
import stellarsdk

protocol HorizonProxyAPI {
    func accountResponse(for accountID: String) -> AnyPublisher<AccountResponse, StellarNetworkError>
    func minimumBalance(subentryCount: UInt) -> CryptoValue
    func sign(transaction: stellarsdk.Transaction, keyPair: stellarsdk.KeyPair) -> Completable
    func submitTransaction(transaction: stellarsdk.Transaction) -> Single<TransactionPostResponseEnum>
}

final class HorizonProxy: HorizonProxyAPI {

    // MARK: Private Properties

    private let configurationService: StellarConfigurationServiceAPI
    private let walletOptions: WalletOptionsAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI

    private let minReserve = BigInt(5000000)

    init(
        configurationService: StellarConfigurationServiceAPI,
        accountRepository: StellarWalletAccountRepositoryAPI,
        walletOptions: WalletOptionsAPI
    ) {
        self.configurationService = configurationService
        self.walletOptions = walletOptions
        self.accountRepository = accountRepository
    }

    func sign(transaction: stellarsdk.Transaction, keyPair: stellarsdk.KeyPair) -> Completable {
        configurationService
            .configuration
            .map(\.network)
            .asSingle()
            .flatMapCompletable(weak: self) { (self, network) -> Completable in
                self.sign(transaction: transaction, keyPair: keyPair, network: network)
            }
    }

    private func sign(transaction: stellarsdk.Transaction, keyPair: stellarsdk.KeyPair, network: Network) -> Completable {
        Completable.fromCallable {
            try transaction.sign(keyPair: keyPair, network: network)
        }
    }

    func minimumBalance(subentryCount: UInt) -> CryptoValue {
        CryptoValue.create(minor: BigInt(2 + subentryCount) * minReserve, currency: .stellar)
    }

    func accountResponse(for accountID: String) -> AnyPublisher<AccountResponse, StellarNetworkError> {
        configurationService
            .configuration
            .flatMap { configuration -> AnyPublisher<AccountResponse, StellarNetworkError> in
                configuration.sdk.accounts.getAccountDetails(accountId: accountID)
            }
            .eraseToAnyPublisher()
    }

    func submitTransaction(transaction: stellarsdk.Transaction) -> Single<TransactionPostResponseEnum> {
        configurationService
            .configuration
            .asSingle()
            .flatMap(weak: self) { (self, configuration) -> Single<TransactionPostResponseEnum> in
                self.submitTransaction(transaction: transaction, with: configuration)
            }
    }

    private func submitTransaction(
        transaction: stellarsdk.Transaction,
        with configuration: StellarConfiguration
    ) -> Single<TransactionPostResponseEnum> {
        Single.create(weak: self) { _, observer -> Disposable in
            do {
                try configuration.sdk.transactions
                    .submitTransaction(transaction: transaction) { response in
                        observer(.success(response))
                    }
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }
}

extension stellarsdk.AccountService {

    fileprivate func getAccountDetails(accountId: String) -> AnyPublisher<AccountResponse, StellarNetworkError> {
        Deferred {
            Future<AccountResponse, StellarNetworkError> { promise in
                self.getAccountDetails(
                    accountId: accountId,
                    response: { response -> Void in
                        switch response {
                        case .success(let details):
                            promise(.success(details))
                        case .failure(let error):
                            promise(.error(error.stellarNetworkError))
                        }
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }
}
