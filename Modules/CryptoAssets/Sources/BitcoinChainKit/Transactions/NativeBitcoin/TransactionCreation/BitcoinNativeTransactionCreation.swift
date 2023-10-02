// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import MetadataHDWalletKit
import MoneyKit
import ToolKit

enum NativeBuildTransactionError: Error {
    case addressMissingForImportedAddress
}

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
    let keyPairs: [WalletKeyPair]
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
) -> AnyPublisher<NativeSignedBitcoinTransaction, Error> {
    signingService.sign(candidate: candidate)
        .eraseError()
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
    let keyPairs = pendingTransaction.keyPairs
    let transactionAddresses: TransactionAddresses
    // check if this source account is an imported (address)
    if sourceAccount.isImported {
        if let xpub = sourceAccount.xpub {
            transactionAddresses = TransactionAddresses(
                changeAddress: xpub.address,
                receiveAddress: xpub.address
            )
        } else {
            return .failure(NativeBuildTransactionError.addressMissingForImportedAddress)
        }
    } else {
        transactionAddresses = getTransactionAddresses(
            context: transactionContext
        )
    }
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
