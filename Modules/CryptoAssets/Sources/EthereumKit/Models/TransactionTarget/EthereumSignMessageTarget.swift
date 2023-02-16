// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import PlatformKit

public struct EthereumSignMessageTarget: WalletConnectTarget {

    public enum Message {
        /// The Data message to be signed.
        /// Used for `eth_sign` and `personal_sign` WalletConnect methods.
        case data(Data)
        /// The String typed data message to be signed.
        /// Used for `eth_signTypedData` WalletConnect method.
        case typedData(String)
    }

    // MARK: - Public Properties

    public let account: String
    public let dAppAddress: String
    public let dAppLogoURL: String
    public let dAppName: String
    public let message: Message
    public let network: EVMNetwork
    public let onTransactionRejected: () -> AnyPublisher<Void, Never>
    public let onTxCompleted: TxCompleted

    public var currencyType: CurrencyType {
        network.nativeAsset.currencyType
    }

    public var label: String {
        dAppName
    }

    public let assetName: String = ""

    var readableMessage: String {
        switch message {
        case .typedData(let typedDataJson):
            let data = Data(typedDataJson.utf8)
            let decoded = try? JSONDecoder().decode(
                TypedDataPayload.self,
                from: data
            )
            return decoded
                .flatMap { typedDataPayload in
                    typedDataPayload.message.description
                }
                ?? typedDataJson

        case .data(let data):
            return String(data: data, encoding: .utf8)
                ?? data.hexString.withHex
        }
    }

    public init(
        account: String,
        dAppAddress: String,
        dAppLogoURL: String,
        dAppName: String,
        message: Message,
        network: EVMNetwork,
        onTransactionRejected: @escaping () -> AnyPublisher<Void, Never>,
        onTxCompleted: @escaping TxCompleted
    ) {
        self.account = account
        self.dAppAddress = dAppAddress
        self.dAppLogoURL = dAppLogoURL
        self.dAppName = dAppName
        self.message = message
        self.network = network
        self.onTransactionRejected = onTransactionRejected
        self.onTxCompleted = onTxCompleted
    }
}
