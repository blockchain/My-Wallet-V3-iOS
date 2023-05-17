// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Errors
import Foundation
import MoneyKit
import ToolKit

final class TransactionService: DelegatedCustodyTransactionServiceAPI {

    private let authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI
    private let client: TransactionsClientAPI
    private let signingService: DelegatedCustodySigningServiceAPI

    private let cachedBuildTransaction: CachedValueNew<
        DelegatedCustodyTransactionInput,
        DelegatedCustodyTransactionOutput,
        DelegatedCustodyTransactionServiceError
    >

    init(
        client: TransactionsClientAPI,
        authenticationDataRepository: DelegatedCustodyAuthenticationDataRepositoryAPI,
        signingService: DelegatedCustodySigningServiceAPI
    ) {
        self.authenticationDataRepository = authenticationDataRepository
        self.client = client
        self.signingService = signingService

        let cacheBuildTransaction: AnyCache<
            DelegatedCustodyTransactionInput,
            DelegatedCustodyTransactionOutput
        > = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 15)
        ).eraseToAnyCache()
        self.cachedBuildTransaction = CachedValueNew(
            cache: cacheBuildTransaction,
            fetch: { [authenticationDataRepository, client] transaction in
                authenticationDataRepository.authenticationData
                    .mapError(DelegatedCustodyTransactionServiceError.authenticationError)
                    .flatMap { [client] authenticationData in
                        client.buildTx(
                            guidHash: authenticationData.guidHash,
                            sharedKeyHash: authenticationData.sharedKeyHash,
                            transaction: transaction
                        )
                        .mapError(DelegatedCustodyTransactionServiceError.networkError)
                    }
                    .map(DelegatedCustodyTransactionOutput.init(response:))
                    .eraseToAnyPublisher()
            }
        )
    }

    func buildTransaction(
        _ transaction: DelegatedCustodyTransactionInput
    ) -> AnyPublisher<DelegatedCustodyTransactionOutput, DelegatedCustodyTransactionServiceError> {
        cachedBuildTransaction.get(key: transaction)
    }

    func sign(
        _ transaction: DelegatedCustodyTransactionOutput,
        privateKey: Data
    ) -> Result<DelegatedCustodySignedTransactionOutput, DelegatedCustodyTransactionServiceError> {
        transaction.preImages
            .map { [signingService] preImage in
                signingService.sign(
                    data: Data(hex: preImage.preImage),
                    privateKey: privateKey,
                    algorithm: preImage.signatureAlgorithm
                )
                .map { signedData -> DelegatedCustodySignedTransactionOutput.SignedPreImage in
                    DelegatedCustodySignedTransactionOutput.SignedPreImage(
                        preImage: preImage.preImage,
                        signingKey: preImage.signingKey,
                        signatureAlgorithm: preImage.signatureAlgorithm,
                        signature: signedData.toHexString
                    )
                }
            }
            .zip()
            .mapError(DelegatedCustodyTransactionServiceError.signing)
            .map { signatures in
                DelegatedCustodySignedTransactionOutput(rawTx: transaction.rawTx, signatures: signatures)
            }
    }

    func pushTransaction(
        _ transaction: DelegatedCustodySignedTransactionOutput,
        currency: CryptoCurrency
    ) -> AnyPublisher<String, DelegatedCustodyTransactionServiceError> {
        authenticationDataRepository.authenticationData
            .mapError(DelegatedCustodyTransactionServiceError.authenticationError)
            .flatMap { [client] authenticationData in
                client.pushTx(
                    guidHash: authenticationData.guidHash,
                    sharedKeyHash: authenticationData.sharedKeyHash,
                    transaction: PushTxRequestData(currency: currency, transaction: transaction)
                )
                .mapError(DelegatedCustodyTransactionServiceError.networkError)
            }
            .map(\.txId)
            .eraseToAnyPublisher()
    }
}

extension DelegatedCustodyTransactionOutput {
    init(response: BuildTxResponse) {
        self.init(
            relativeFee: response.summary.relativeFee,
            absoluteFeeMaximum: response.summary.absoluteFeeMaximum,
            absoluteFeeEstimate: response.summary.absoluteFeeEstimate,
            amount: response.summary.amount,
            balance: response.summary.balance,
            rawTx: response.rawTx,
            preImages: response.preImages.map(PreImage.init(response:))
        )
    }
}

extension DelegatedCustodyTransactionOutput.PreImage {
    init(response: BuildTxResponse.PreImage) {
        self.init(
            preImage: response.preImage,
            signingKey: response.signingKey,
            descriptor: response.descriptor,
            signatureAlgorithm: response.signatureAlgorithm.delegatedCustodySignatureAlgorithm
        )
    }
}

extension DelegatedCustodySignatureAlgorithm {
    var signatureAlgorithmResponse: SignatureAlgorithmResponse {
        switch self {
        case .secp256k1:
            return .secp256k1
        }
    }
}

extension SignatureAlgorithmResponse {
    var delegatedCustodySignatureAlgorithm: DelegatedCustodySignatureAlgorithm {
        switch self {
        case .secp256k1:
            return .secp256k1
        }
    }
}

extension PushTxRequestData {
    init(currency: CryptoCurrency, transaction: DelegatedCustodySignedTransactionOutput) {
        self.currency = currency.code
        rawTx = transaction.rawTx
        signatures = transaction.signatures.map { signature in
            PushTxRequestData.Signature(
                preImage: signature.preImage,
                signingKey: signature.signingKey,
                signatureAlgorithm: signature.signatureAlgorithm.signatureAlgorithmResponse,
                signature: signature.signature
            )
        }
    }
}
