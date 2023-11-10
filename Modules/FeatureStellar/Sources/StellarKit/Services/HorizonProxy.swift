// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Foundation
import MoneyKit
import stellarsdk

protocol HorizonProxyAPI {
    func accountResponse(for accountID: String) -> AnyPublisher<AccountResponse, StellarNetworkError>
    func sign(transaction: stellarsdk.Transaction, keyPair: stellarsdk.KeyPair) -> AnyPublisher<Void, Error>
    func submitTransaction(transaction: stellarsdk.Transaction) -> AnyPublisher<TransactionPostResponseEnum, Error>
}

final class HorizonProxy: HorizonProxyAPI {

    // MARK: Private Properties

    private let configurationService: StellarConfigurationServiceAPI

    init(configurationService: StellarConfigurationServiceAPI) {
        self.configurationService = configurationService
    }

    func sign(transaction: stellarsdk.Transaction, keyPair: stellarsdk.KeyPair) -> AnyPublisher<Void, Error> {
        configurationService
            .configuration
            .map(\.network)
            .tryMap { network in
                try transaction.sign(keyPair: keyPair, network: network)
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func accountResponse(for accountID: String) -> AnyPublisher<AccountResponse, StellarNetworkError> {
        configurationService
            .configuration
            .flatMap { configuration -> AnyPublisher<AccountResponse, StellarNetworkError> in
                configuration.sdk.accounts.getAccountDetails(accountId: accountID)
            }
            .eraseToAnyPublisher()
    }

    func submitTransaction(transaction: stellarsdk.Transaction) -> AnyPublisher<TransactionPostResponseEnum, Error> {
        configurationService
            .configuration
            .flatMap { configuration -> AnyPublisher<TransactionPostResponseEnum, Error> in
                configuration.sdk.transactions.submit(transaction: transaction)
            }
            .eraseToAnyPublisher()
    }
}

private let minReserve = BigInt(5000000)
func stellarMinimumBalance(subentryCount: UInt) -> CryptoValue {
    CryptoValue.create(minor: BigInt(2 + subentryCount) * minReserve, currency: .stellar)
}

extension stellarsdk.TransactionsService {
    fileprivate func submit(
        transaction: stellarsdk.Transaction
    ) -> AnyPublisher<TransactionPostResponseEnum, Error> {
        Deferred {
            Future { promise in
                do {
                    try self.submitTransaction(transaction: transaction) { response in
                        promise(.success(response))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()

    }
}

extension stellarsdk.AccountService {

    fileprivate func getAccountDetails(accountId: String) -> AnyPublisher<AccountResponse, StellarNetworkError> {
        Deferred {
            Future<AccountResponse, StellarNetworkError> { promise in
                self.getAccountDetails(accountId: accountId) { response -> Void in
                    switch response {
                    case .success(let details):
                        promise(.success(details))
                    case .failure(let error):
                        promise(.error(error.stellarNetworkError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
