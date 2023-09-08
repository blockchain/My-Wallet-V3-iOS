// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit

protocol TransactionCandidateProviderAPI {
    func getCandidate(
        sourceAccount: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        amount: CryptoValue,
        feeLevel: BitcoinChainPendingTransaction.FeeLevel
    ) -> AnyPublisher<NativeBitcoinTransactionCandidate, Error>

    func getMaxSpendable(
        sourceAccount: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        amount: CryptoValue,
        feeLevel: BitcoinChainPendingTransaction.FeeLevel
    ) -> AnyPublisher<CryptoValue, Error>
}

final class TransactionCandidateProvider<Token: BitcoinChainToken>: TransactionCandidateProviderAPI {

    private lazy var nativeBitcoinEnvironment: NativeBitcoinEnvironment = .init(
        unspentOutputRepository: DIKit.resolve(
            tag: Token.coin
        ),
        buildingService: resolve(tag: Token.coin),
        signingService: resolve(tag: Token.coin),
        sendingService: resolve(tag: Token.coin),
        fetchMultiAddressFor: resolve(tag: Token.coin),
        mnemonicProvider: resolve()
    )

    private let buildService: BitcoinChainTransactionBuildingServiceAPI
    private let feeRepository: AnyCryptoFeeRepository<BitcoinChainTransactionFee<Token>>

    init(
        buildService: BitcoinChainTransactionBuildingServiceAPI,
        feeRepository: AnyCryptoFeeRepository<BitcoinChainTransactionFee<Token>> = resolve(tag: Token.coin)
    ) {
        self.buildService = buildService
        self.feeRepository = feeRepository
    }

    func transactionContextAndSource(
        sourceAccount: BitcoinChainCryptoAccount
    ) -> AnyPublisher<(source: BitcoinChainAccount, context: NativeBitcoinTransactionContext), Error> {
        let source = BitcoinChainAccount(
            index: Int32(sourceAccount.hdAccountIndex),
            coin: sourceAccount.coinType,
            xpub: sourceAccount.xPub,
            importedPrivateKey: sourceAccount.importedPrivateKey,
            isImported: sourceAccount.isImported
        )
        let transactionContextProvider = getTransactionContextProvider(
            walletMnemonicProvider: nativeBitcoinEnvironment.mnemonicProvider,
            fetchUnspentOutputsFor: nativeBitcoinEnvironment.unspentOutputRepository.unspentOutputs(for:),
            fetchMultiAddressFor: nativeBitcoinEnvironment.fetchMultiAddressFor
        )

        return getTransactionContext(
            for: source,
            transactionContextFor: transactionContextProvider
        )
        .map { context in (source, context) }
        .eraseToAnyPublisher()
    }

    /// Calculates the max spendable amount from the given parameters
    /// - Returns: `AnyPublisher<CryptoValue, Error>`
    func getCandidate(
        sourceAccount: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        amount: CryptoValue,
        feeLevel: BitcoinChainPendingTransaction.FeeLevel
    ) -> AnyPublisher<NativeBitcoinTransactionCandidate, Error> {
        Publishers.Zip(
            transactionContextAndSource(sourceAccount: sourceAccount),
            fetchFee(for: feeLevel, feeRepository: feeRepository).compactMap(\.cryptoValue).mapError()
        )
        .flatMap { [buildService] contextAndSource, fee in
            let (source, context) = contextAndSource
            let tempTx = BitcoinChainPendingTransaction(
                amount: amount,
                destinationAddress: target.address,
                feeLevel: feeLevel,
                unspentOutputs: context.unspentOutputs,
                keyPairs: context.keyPairs
            )
            return nativeBuildTransaction(
                sourceAccount: source,
                pendingTransaction: tempTx,
                feePerByte: fee,
                transactionContext: context,
                buildingService: buildService
            )
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func getMaxSpendable(
        sourceAccount: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        amount: CryptoValue,
        feeLevel: BitcoinChainPendingTransaction.FeeLevel
    ) -> AnyPublisher<CryptoValue, Error> {
        getCandidate(
            sourceAccount: sourceAccount,
            target: target,
            amount: amount,
            feeLevel: feeLevel
        )
        .map(\.maxValue.available)
        .eraseToAnyPublisher()
    }
}
