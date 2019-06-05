//
//  EthereumWalletService.swift
//  EthereumKit
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt
import PlatformKit
import RxSwift

enum EthereumWalletServiceError: Error {
    case unknown
    case waitingOnPendingTransaction
}

public protocol EthereumWalletServiceAPI {
    func buildTransaction(with value: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate>
    func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished>
}

public final class EthereumWalletService: EthereumWalletServiceAPI {
    public typealias Bridge = EthereumWalletBridgeAPI
    
    private var isWaitingOnEtherTransaction: Single<Void> {
        return bridge.isWaitingOnEtherTransaction
            .flatMap { isWaiting -> Single<Void> in
                guard !isWaiting else {
                    throw EthereumWalletServiceError.waitingOnPendingTransaction
                }
                return Single.just(())
            }
    }
    
    private var fetchBalance: Single<CryptoValue> {
        return bridge.fetchBalance
    }
    
    private var loadKeyPair: Single<EthereumKeyPair> {
        return walletAccountRepository.keyPair.asObservable().asSingle()
    }
    
    private let bridge: Bridge
    private let ethereumAPIClient: EthereumAPIClientAPI
    private let feeService: EthereumFeeServiceAPI
    private let walletAccountRepository: EthereumWalletAccountRepositoryAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let transactionSendingService: EthereumTransactionSendingServiceAPI
    
    public init(with bridge: Bridge,
                ethereumAPIClient: EthereumAPIClientAPI,
                feeService: EthereumFeeServiceAPI,
                walletAccountRepository: EthereumWalletAccountRepositoryAPI,
                transactionBuildingService: EthereumTransactionBuildingServiceAPI,
                transactionSendingService: EthereumTransactionSendingServiceAPI) {
        self.bridge = bridge
        self.ethereumAPIClient = ethereumAPIClient
        self.feeService = feeService
        self.walletAccountRepository = walletAccountRepository
        self.transactionBuildingService = transactionBuildingService
        self.transactionSendingService = transactionSendingService
    }
    
    public func buildTransaction(with value: EthereumValue, to: EthereumAddress) -> Single<EthereumTransactionCandidate> {
        return transactionBuildingService.buildTransaction(with: value, to: to)
    }
    
    public func send(transaction: EthereumTransactionCandidate) -> Single<EthereumTransactionPublished> {
        return isWaitingOnEtherTransaction
            .flatMap(weak: self) { (self, _) -> Single<EthereumKeyPair> in
                self.loadKeyPair
            }
            .flatMap(weak: self) { (self, keyPair) -> Single<EthereumTransactionPublished> in
                self.prepareAndPush(transaction: transaction, keyPair: keyPair)
            }
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                self.recordAndUpdateBalance(transaction: transaction)
            }
    }
    
    private func prepareAndPush(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished> {
        return transactionSendingService.send(
            transaction: transaction,
            keyPair: keyPair
        )
    }
    
    private func recordAndUpdateBalance(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        return record(transaction: transaction)
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                return self.fetchBalance.map { _ -> EthereumTransactionPublished in
                    transaction
                }
            }
    }
    
    private func record(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        return bridge.recordLast(transaction: transaction)
    }
}
