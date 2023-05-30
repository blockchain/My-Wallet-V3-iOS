// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol FilePathProviderAPI {
    func url(fileName: String, from origin: FileOrigin) -> URL?
}

extension FilePathProviderAPI {
    func url(fileName: FileName) -> URL? {
        url(fileName: fileName.rawValue, from: fileName.origin)
    }
}

enum FileOrigin: Hashable {
    case bundle
    case documentsDirectory
}

final class FilePathProvider: FilePathProviderAPI {

    private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func url(fileName: String, from origin: FileOrigin) -> URL? {
        switch origin {
        case .bundle:
            return bundle(fileName: fileName)
        case .documentsDirectory:
            return documentsDirectory(fileName: fileName)
        }
    }

    private func bundle(fileName: String) -> URL? {
        Bundle.module.url(forResource: fileName, withExtension: nil)
    }

    private func documentsDirectory(fileName: String) -> URL? {
        guard let documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }

    private var documentsDirectory: URL? {
        try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
}
