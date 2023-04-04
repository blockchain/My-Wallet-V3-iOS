// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import FeatureTransactionDomain
import Foundation
import MoneyKit
import PlatformKit

public protocol EthereumTransactionBuildingServiceAPI {
    func buildTransaction(
        amount: MoneyValue,
        to address: EthereumAddress,
        addressReference: EthereumAddress?,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        nonce: BigUInt,
        chainID: BigUInt,
        contractAddress: EthereumAddress?
    ) -> Result<EthereumTransactionCandidate, Never>

    func buildTransaction(
        amount: MoneyValue,
        to address: EthereumAddress,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        nonce: BigUInt,
        chainID: BigUInt,
        transferType: EthereumTransactionCandidate.TransferType
    ) -> Result<EthereumTransactionCandidate, Never>
}

final class EthereumTransactionBuildingService: EthereumTransactionBuildingServiceAPI {

    func buildTransaction(
        amount: MoneyValue,
        to address: EthereumAddress,
        addressReference: EthereumAddress?,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        nonce: BigUInt,
        chainID: BigUInt,
        contractAddress: EthereumAddress?
    ) -> Result<EthereumTransactionCandidate, Never> {
        buildTransaction(
            amount: amount,
            to: address,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            nonce: nonce,
            chainID: chainID,
            transferType: transferType(
                addressReference: addressReference,
                contractAddress: contractAddress
            )
        )
    }

    func buildTransaction(
        amount: MoneyValue,
        to address: EthereumAddress,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        nonce: BigUInt,
        chainID: BigUInt,
        transferType: EthereumTransactionCandidate.TransferType
    ) -> Result<EthereumTransactionCandidate, Never> {
        .success(
            EthereumTransactionCandidate(
                to: address,
                gasPrice: gasPrice,
                gasLimit: gasLimit,
                value: BigUInt(amount.minorAmount),
                nonce: nonce,
                chainID: chainID,
                transferType: transferType
            )
        )
    }

    /// Creates a EthereumTransactionCandidate.TransferType based on the presence of address reference and contract address.
    /// - Parameter addressReference: EthereumAddress of the reference address if it exists. If there is no reference address
    /// in this transaction, then this will be nil.
    /// - Parameter contractAddress: EthereumAddress of the contract address if it exists. If there is no contract address
    /// (non-ERC20 transaction) in this transaction, then this will be nil.
    private func transferType(
        addressReference: EthereumAddress?,
        contractAddress: EthereumAddress?
    ) -> EthereumTransactionCandidate.TransferType {
        if let contractAddress {
            return .erc20Transfer(contract: contractAddress, addressReference: addressReference)
        } else {
            let data: Data? = addressReference.flatMap { address in
                Data(hex: address.publicKey)
            }
            return .transfer(data: data)
        }
    }
}

extension FeeLevel {
    public var ethereumFeeLevel: EthereumTransactionFee.FeeLevel {
        switch self {
        case .custom, .none, .regular:
            return .regular
        case .priority:
            return .priority
        }
    }
}
