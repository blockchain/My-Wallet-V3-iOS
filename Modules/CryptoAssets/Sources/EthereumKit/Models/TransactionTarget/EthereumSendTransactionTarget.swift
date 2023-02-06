// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import PlatformKit

public struct EthereumSendTransactionTarget: WalletConnectTarget {

    public enum Method {
        case sign
        case send
    }

    // MARK: - Public Properties

    public let onTxCompleted: TxCompleted
    public let onTransactionRejected: () -> AnyPublisher<Void, Never>
    public var currencyType: CurrencyType {
        network.nativeAsset.currencyType
    }

    public var label: String {
        dAppName
    }

    public let assetName: String = ""

    // MARK: - Properties

    let dAppAddress: String
    let dAppLogoURL: String
    let dAppName: String
    let method: Method
    let network: EVMNetwork
    let transaction: EthereumJsonRpcTransaction

    // MARK: - Init

    public init(
        dAppAddress: String,
        dAppLogoURL: String,
        dAppName: String,
        method: Method,
        network: EVMNetwork,
        onTransactionRejected: @escaping () -> AnyPublisher<Void, Never>,
        onTxCompleted: @escaping TxCompleted,
        transaction: EthereumJsonRpcTransaction
    ) {
        self.dAppAddress = dAppAddress
        self.dAppLogoURL = dAppLogoURL
        self.dAppName = dAppName
        self.method = method
        self.network = network
        self.onTransactionRejected = onTransactionRejected
        self.onTxCompleted = onTxCompleted
        self.transaction = transaction
    }
}
