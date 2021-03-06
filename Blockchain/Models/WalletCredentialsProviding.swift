// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol WalletCredentialsProviding: AnyObject {
    var legacyPassword: String? { get }
}
