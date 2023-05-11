// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import NetworkKit
import ToolKit

protocol TransactionsClientAPI {
    func buildTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: DelegatedCustodyTransactionInput
    ) -> AnyPublisher<BuildTxResponse, NetworkError>

    func pushTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: PushTxRequestData
    ) -> AnyPublisher<PushTxResponse, NetworkError>
}

extension Client: TransactionsClientAPI {

    private struct PushTxRequestPayload: Encodable {
        struct Signature: Encodable {
            let preImage: String
            let signingKey: String
            let signatureAlgorithm: SignatureAlgorithmResponse
            let signature: String
        }

        let auth: AuthDataPayload
        let currency: String
        let rawTx: JSONValue
        let signatures: [Signature]
    }

    func buildTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: DelegatedCustodyTransactionInput
    ) -> AnyPublisher<BuildTxResponse, NetworkError> {
        let payload = BuildTxRequestPayload(
            input: transaction,
            guidHash: guidHash,
            sharedKeyHash: sharedKeyHash
        )
        let request = requestBuilder
            .post(
                path: Endpoint.buildTx,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
    }

    func pushTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: PushTxRequestData
    ) -> AnyPublisher<PushTxResponse, NetworkError> {
        let payload = PushTxRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            currency: transaction.currency,
            rawTx: transaction.rawTx,
            signatures: transaction.signatures.map { signature in
                PushTxRequestPayload.Signature(
                    preImage: signature.preImage,
                    signingKey: signature.signingKey,
                    signatureAlgorithm: signature.signatureAlgorithm,
                    signature: signature.signature
                )
            }
        )
        let request = requestBuilder
            .post(
                path: Endpoint.pushTx,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
    }
}
