// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum WalletConnectSupportedMethods: String, CaseIterable {
    case ethSendTransaction = "eth_sendTransaction"
    case ethSignTransaction = "eth_signTransaction"
    case ethSign = "eth_sign"
    case ethSignTypedData = "eth_signTypedData"
    case personalSign = "personal_sign"

    public static var allMethods: Set<String> {
        Set(allCases.map(\.rawValue))
    }
}

public enum WalletConnectSignMethod: String {
    case personalSign = "personal_sign"
    case ethSign = "eth_sign"
    case ethSignTypedData = "eth_signTypedData"

    private var dataIndex: Int {
        switch self {
        case .personalSign:
            return 0
        case .ethSign, .ethSignTypedData:
            return 1
        }
    }

    private var addressIndex: Int {
        switch self {
        case .personalSign:
            return 1
        case .ethSign, .ethSignTypedData:
            return 0
        }
    }

    func address(from params: [String]) -> String? {
        guard addressIndex <= params.count else {
            return nil
        }
        return params[addressIndex]
    }

    func message(from params: [String]) -> String? {
        guard dataIndex <= params.count else {
            return nil
        }
        return params[dataIndex]
    }
}
