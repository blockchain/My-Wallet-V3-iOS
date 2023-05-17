// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct DelegatedCustodyTransactionOutput: Hashable {

    public struct PreImage: Hashable {

        public let preImage: String
        public let signingKey: String
        public let descriptor: String?
        public let signatureAlgorithm: DelegatedCustodySignatureAlgorithm

        public init(
            preImage: String,
            signingKey: String,
            descriptor: String?,
            signatureAlgorithm: DelegatedCustodySignatureAlgorithm
        ) {
            self.preImage = preImage
            self.signingKey = signingKey
            self.descriptor = descriptor
            self.signatureAlgorithm = signatureAlgorithm
        }
    }

    public let relativeFee: String
    public let absoluteFeeMaximum: String
    public let absoluteFeeEstimate: String
    public let amount: String?
    public let balance: String?
    public let rawTx: JSONValue
    public let preImages: [PreImage]

    public init(
        relativeFee: String,
        absoluteFeeMaximum: String,
        absoluteFeeEstimate: String,
        amount: String?,
        balance: String?,
        rawTx: JSONValue,
        preImages: [DelegatedCustodyTransactionOutput.PreImage]
    ) {
        self.relativeFee = relativeFee
        self.absoluteFeeMaximum = absoluteFeeMaximum
        self.absoluteFeeEstimate = absoluteFeeEstimate
        self.amount = amount
        self.balance = balance
        self.rawTx = rawTx
        self.preImages = preImages
    }
}

public enum DelegatedCustodySigningError: Error {
    case failed
}

public enum DelegatedCustodySignatureAlgorithm: Hashable {
    case secp256k1
}

public protocol DelegatedCustodySigningServiceAPI {
    func sign(
        data: Data,
        privateKey: Data,
        algorithm: DelegatedCustodySignatureAlgorithm
    ) -> Result<Data, DelegatedCustodySigningError>
}
