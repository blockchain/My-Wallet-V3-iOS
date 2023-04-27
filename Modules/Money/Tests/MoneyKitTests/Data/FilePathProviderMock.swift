// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MoneyKit
import MoneyKit

final class FilePathProviderMock: FilePathProviderAPI {
    struct Key: Hashable {
        let fileName: String
        let origin: FileOrigin
    }

    var underlyingURLs: [Key: URL] = [:]

    func url(fileName: String, from origin: FileOrigin) -> URL? {
        underlyingURLs[Key(fileName: fileName, origin: origin)]
    }
}

final class EVMSupportMock: EVMSupportAPI {

    var sanitizeTokenNamesEnabled: Bool = false

    var underlyingIsEnabled = false
    func isEnabled(network: String) -> Bool {
        underlyingIsEnabled
    }
}
