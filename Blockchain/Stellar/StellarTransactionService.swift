//
//  StellarTransactionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import stellarsdk

class StellarTransactionService: StellarTransactionAPI {
    
    typealias TransactionResult = StellarTransactionResponse.Result
    typealias StellarAssetType = stellarsdk.AssetType
    typealias StellarTransaction = stellarsdk.Transaction
    
    fileprivate let configuration: StellarConfiguration
    fileprivate let accounts: StellarAccountAPI
    fileprivate let repository: WalletXlmAccountRepository
    fileprivate lazy var service: stellarsdk.TransactionsService = {
        configuration.sdk.transactions
    }()
    
    init(
        configuration: StellarConfiguration = .production,
        accounts: StellarAccountAPI,
        repository: WalletXlmAccountRepository
    ) {
        self.configuration = configuration
        self.accounts = accounts
        self.repository = repository
    }

    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKeyPair) -> Completable {
        // TODO: handle case when sending to an unfunded address
        // TICKET: IOS-1524
        return accounts.accountResponse(for: sourceKeyPair.accountId)
            .flatMapCompletable { [weak self] accountResponse -> Completable in
                guard let strongSelf = self else {
                    return Completable.empty()
                }
                return strongSelf.send(paymentOperation, accountResponse: accountResponse, sourceKeyPair: sourceKeyPair)
            }
    }
    
    func get(transaction transactionHash: String, completion: @escaping ((Result<StellarTransactionResponse>) -> Void)) {
        service.getTransactionDetails(transactionHash: transactionHash) { response -> Void in
            switch response {
            case .success(let details):
                let code = details.transactionResult.code.rawValue
                let result: TransactionResult = code == 0 ? .success : .error(StellarTransactionError(rawValue: Int(code)) ?? .internalError)
                var memo: String?
                if let detailsMemo = details.memo {
                    if case let .text(value) = detailsMemo {
                        memo = value
                    }
                }
                
                let value = StellarTransactionResponse(
                    identifier: details.id,
                    result: result,
                    transactionHash: details.transactionHash,
                    createdAt: details.createdAt,
                    sourceAccount: details.sourceAccount,
                    feePaid: details.feePaid,
                    memo: memo
                )
                DispatchQueue.main.async {
                    completion(.success(value))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            }
        }
    }

    private func send(
        _ paymentOperation: StellarPaymentOperation,
        accountResponse: AccountResponse,
        sourceKeyPair: StellarKeyPair
    ) -> Completable {
        return Completable.create(subscribe: { [weak self] event -> Disposable in
            guard let strongSelf = self else {
                return Disposables.create()
            }
            do {
                // Assemble objects
                let source = try KeyPair(secretSeed: sourceKeyPair.secret)
                let destination = try KeyPair(accountId: paymentOperation.destinationAccountId)
                let payment = PaymentOperation(
                    sourceAccount: source,
                    destination: destination,
                    asset: Asset(type: StellarAssetType.ASSET_TYPE_NATIVE)!,
                    amount: paymentOperation.amountInXlm
                )
                let transaction = try StellarTransaction(
                    sourceAccount: accountResponse,
                    operations: [payment],
                    memo: Memo.none,
                    timeBounds: nil
                )

                // Sign transaction
                try transaction.sign(keyPair: source, network: strongSelf.configuration.network)

                // Perform network operation
                try strongSelf.configuration.sdk.transactions
                    .submitTransaction(transaction: transaction, response: { response -> (Void) in
                        switch response {
                        case .success(details: _):
                            event(.completed)
                        case .failure(let error):
                            event(.error(error))
                        }
                    })
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
    
}
