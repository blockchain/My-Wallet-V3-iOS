// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MetadataHDWalletKit
import MoneyKit
import ToolKit

struct NativeBitcoinEnvironment {
    let unspentOutputRepository: UnspentOutputRepositoryAPI
    let buildingService: BitcoinChainTransactionBuildingServiceAPI
    let signingService: BitcoinChainTransactionSigningServiceAPI
    let sendingService: BitcoinTransactionSendingServiceAPI
    let fetchMultiAddressFor: FetchMultiAddressFor
    let mnemonicProvider: WalletMnemonicProvider
}

struct BitcoinChainPendingTransaction {

    enum FeeLevel: Equatable {
        case regular
        case priority
        case custom(CryptoValue)
    }

    let amount: CryptoValue
    let destinationAddress: String
    let feeLevel: FeeLevel
    let unspentOutputs: [UnspentOutput]
}

public enum TransactionOutcome {
    case signed(rawTx: String)
    case hashed(txHash: String, amount: CryptoValue?)
}

typealias FeeFromPendingTransaction =
    (BitcoinChainPendingTransaction) -> AnyPublisher<CryptoValue, Never>

func nativeSignTransaction(
    candidate: NativeBitcoinTransactionCandidate,
    signingService: BitcoinChainTransactionSigningServiceAPI
) -> AnyPublisher<NativeEngineTransaction, Error> {
    signingService.sign(candidate: candidate)
        .eraseError()
        .map { signedTransaction in
            NativeEngineTransaction(
                encodedMsg: signedTransaction.encodedMsg,
                msgSize: signedTransaction.msgSize,
                txHash: signedTransaction.txHash
            )
        }
        .eraseToAnyPublisher()
}

func nativeExecuteTransaction(
    candidate: NativeBitcoinTransactionCandidate,
    environment: NativeBitcoinEnvironment
) -> AnyPublisher<TransactionOutcome, Error> {
    let signingService = environment.signingService
    let sendingService = environment.sendingService
    return signingService
        .sign(candidate: candidate)
        .eraseError()
        .flatMap { signedTransaction in
            sendingService.send(signedTransaction: signedTransaction)
                .eraseError()
        }
        .map { txHash in
            TransactionOutcome.hashed(
                txHash: txHash,
                amount: candidate.amount
            )
        }
        .eraseToAnyPublisher()
}

func nativeBuildTransaction(
    sourceAccount: BitcoinChainAccount,
    pendingTransaction: BitcoinChainPendingTransaction,
    feePerByte: CryptoValue,
    transactionContext: NativeBitcoinTransactionContext,
    buildingService: BitcoinChainTransactionBuildingServiceAPI
) -> AnyPublisher<NativeBitcoinTransactionCandidate, Error> {
    let amount = pendingTransaction.amount
    let unspentOutputs = pendingTransaction.unspentOutputs
    let keyPairs = getWalletKeyPairs(
        unspentOutputs: unspentOutputs,
        accountKeyContext: transactionContext.accountKeyContext
    )
    let transactionAddresses = getTransactionAddresses(
        context: transactionContext
    )
    let destinationAddress = pendingTransaction.destinationAddress
    let changeAddress = transactionAddresses.changeAddress
    return buildingService
        .buildCandidate(
            keys: keyPairs,
            unspentOutputs: unspentOutputs,
            changeAddress: changeAddress,
            destinationAddress: destinationAddress,
            amount: amount,
            feePerByte: feePerByte
        )
        .eraseError()
}
