// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import PlatformKit

public struct EthereumRawTransactionTarget: WalletConnectTarget {

    // MARK: - Public Properties

    public let onTxCompleted: TxCompleted
    public let onTransactionRejected: () -> AnyPublisher<Void, Never>
    public let currencyType: CurrencyType = .crypto(.ethereum)
    public var label: String {
        dAppName
    }
    public let assetName: String = ""

    // MARK: - Properties

    let dAppAddress: String
    let dAppName: String
    let dAppLogoURL: String
    let rawTransaction: Data

    // MARK: - Init

    public init(
        dAppAddress: String,
        dAppName: String,
        dAppLogoURL: String,
        rawTransaction: Data,
        onTxCompleted: @escaping TxCompleted,
        onTransactionRejected: @escaping () -> AnyPublisher<Void, Never>
    ) {
        self.onTxCompleted = onTxCompleted
        self.onTransactionRejected = onTransactionRejected
        self.dAppAddress = dAppAddress
        self.dAppName = dAppName
        self.dAppLogoURL = dAppLogoURL
        self.rawTransaction = rawTransaction
    }
}
