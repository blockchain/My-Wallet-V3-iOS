// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public struct EthereumTransactionFee {

    // MARK: Types

    public enum FeeLevel {
        case regular
        case priority
    }

    // MARK: Static Methods

    private static let defaultRegularFee: BigInt = 5
    private static let defaultPriorityFee: BigInt = 20
    private static let defaultGasLimit: BigUInt = 21000
    private static let defaultGasLimitContract: BigUInt = 75000

    static func `default`(network: EVMNetwork) -> EthereumTransactionFee {
        EthereumTransactionFee(
            regular: .ether(gwei: defaultRegularFee, network: network),
            priority: .ether(gwei: defaultPriorityFee, network: network),
            gasLimit: defaultGasLimit,
            gasLimitContract: defaultGasLimitContract,
            network: network
        )
    }

    // MARK: Private Properties

    private let regular: CryptoValue
    private let priority: CryptoValue
    private let gasLimit: BigUInt
    private let gasLimitContract: BigUInt
    private let network: EVMNetwork

    // MARK: Init

    init(
        regular: CryptoValue,
        priority: CryptoValue,
        gasLimit: BigUInt,
        gasLimitContract: BigUInt,
        network: EVMNetwork
    ) {
        self.regular = regular
        self.priority = priority
        self.gasLimit = gasLimit
        self.gasLimitContract = gasLimitContract
        self.network = network
    }

    init(
        regularGwei: Int,
        priorityGwei: Int,
        gasLimit: Int,
        gasLimitContract: Int,
        network: EVMNetwork
    ) {
        self.init(
            regular: .ether(gwei: BigInt(regularGwei), network: network),
            priority: .ether(gwei: BigInt(priorityGwei), network: network),
            gasLimit: BigUInt(gasLimit),
            gasLimitContract: BigUInt(gasLimitContract),
            network: network
        )
    }

    init(
        regularMinor: String,
        priorityMinor: String,
        gasLimit: String,
        gasLimitContract: String,
        network: EVMNetwork
    ) {
        self.init(
            regular: .create(minor: regularMinor, currency: network.nativeAsset) ?? .ether(gwei: Self.defaultRegularFee, network: network),
            priority: .create(minor: priorityMinor, currency: network.nativeAsset) ?? .ether(gwei: Self.defaultPriorityFee, network: network),
            gasLimit: BigUInt(gasLimit) ?? Self.defaultGasLimit,
            gasLimitContract: BigUInt(gasLimitContract) ?? Self.defaultGasLimitContract,
            network: network
        )
    }

    // MARK: Private Methods

    public func gasPrice(feeLevel: FeeLevel) -> BigUInt {
        switch feeLevel {
        case .regular:
            return BigUInt(regular.minorAmount)
        case .priority:
            return BigUInt(priority.minorAmount)
        }
    }

    public func gasLimit(
        extraGasLimit: BigUInt,
        isContract: Bool
    ) -> BigUInt {
        (isContract ? gasLimitContract : gasLimit) + extraGasLimit
    }

    public func absoluteFee(
        with feeLevel: FeeLevel,
        extraGasLimit: BigUInt,
        isContract: Bool
    ) -> CryptoValue {
        let price = gasPrice(feeLevel: feeLevel)
        let gasLimit = gasLimit(extraGasLimit: extraGasLimit, isContract: isContract)
        let amount = price * gasLimit
        return CryptoValue
            .create(
                minor: BigInt(amount),
                currency: network.nativeAsset
            )
    }
}

extension CryptoValue {

    static func ether(
        gwei: BigInt,
        network: EVMNetwork
    ) -> CryptoValue {
        let wei = gwei * BigInt(1e9)
        return CryptoValue.create(
            minor: wei,
            currency: network.nativeAsset
        )
    }
}
