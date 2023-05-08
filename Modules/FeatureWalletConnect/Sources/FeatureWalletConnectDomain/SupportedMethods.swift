// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum WalletConnectSupportedMethods: String, CaseIterable {
    case ethSendTransaction = "eth_sendTransaction"
    case ethSignTransaction = "eth_signTransaction"
    case ethSign = "eth_sign"
    case ethSignTypedData = "eth_signTypedData"
    case ethSendRawTransaction = "eth_sendRawTransaction"
    case personalSign = "personal_sign"

    public static var allMethods: Set<String> {
        Set(allCases.map(\.rawValue))
    }
}
