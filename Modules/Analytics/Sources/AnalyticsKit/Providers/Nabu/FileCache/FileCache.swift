// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol FileCacheAPI {
    func save(events: [Event])
    func read() -> [Event]?
}

final class FileCache: FileCacheAPI {

    private enum Constants {
        enum AnalyticsFile {
            static let prefix = "analyticsEvents"
            static let suffix = ".cache"
        }
    }

    private let fileManager: FileManager
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private lazy var cacheDirectoryURLs: [URL] = fileManager.urls(
        for: .cachesDirectory,
        in: .userDomainMask
    )

    init(
        fileManager: FileManager = .default,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileManager = fileManager
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func save(events: [Event]) {
        let fileName = "\(Constants.AnalyticsFile.prefix)\(Date.currentTimeStampString)" + Constants.AnalyticsFile.suffix
        guard let fileURL = cacheDirectoryURLs.first?.appendingPathComponent(fileName) else {
            return
        }
        if let data = try? jsonEncoder.encode(events) {
            try? data.write(to: fileURL)
        }
    }

    func read() -> [Event]? {
        guard let path = cacheDirectoryURLs.first else {
            return []
        }
        let contentsOfCacheDirectory = try? fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        return contentsOfCacheDirectory?.filter {
            $0.absoluteString.contains(Constants.AnalyticsFile.prefix) &&
                $0.absoluteString.contains(Constants.AnalyticsFile.suffix)
        }
        .compactMap { [unowned fileManager] url -> [Event]? in
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            try? fileManager.removeItem(at: url)
            return try? jsonDecoder.decode([Event].self, from: data)
        }
        .flatMap { $0 }
    }
}

extension Date {
    fileprivate static var currentTimeStampString: String {
        "\(Int(Date().timeIntervalSince1970 * 1000))"
    }
}
