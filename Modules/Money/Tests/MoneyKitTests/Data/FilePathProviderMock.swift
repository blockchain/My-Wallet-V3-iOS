// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MoneyKit

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
