// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KeychainItemClass: Equatable {
    case genericPassword

    public var queryValue: String {
        switch self {
        case .genericPassword:
            String(kSecClassGenericPassword)
        }
    }
}
