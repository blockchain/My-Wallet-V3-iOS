// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol FileLoaderAPI {
    func load<T>(fileName: FileName, fallBack fallBackFileName: FileName, as type: T.Type) -> Result<T, FileLoaderError> where T: Decodable
    func load<T>(fileName: FileName, as type: T.Type) -> Result<T, FileLoaderError> where T: Decodable
}

enum FileLoaderError: Error {
    case missignFile(FileName)
    case decodingFailed(Error, URL)
}

final class FileLoader: FileLoaderAPI {

    private let filePathProvider: FilePathProviderAPI
    private let jsonDecoder: JSONDecoder

    init(
        filePathProvider: FilePathProviderAPI,
        jsonDecoder: JSONDecoder
    ) {
        self.filePathProvider = filePathProvider
        self.jsonDecoder = jsonDecoder
    }

    func load<T>(fileName: FileName, fallBack fallBackFileName: FileName, as type: T.Type) -> Result<T, FileLoaderError> where T: Decodable {
        switch load(fileName: fileName, as: type) {
        case .success(let decoded):
            return .success(decoded)
        case .failure:
            return load(fileName: fallBackFileName, as: type)
        }
    }

    func load<T>(fileName: FileName, as type: T.Type) -> Result<T, FileLoaderError> where T: Decodable {
        guard let fileURL = filePathProvider.url(fileName: fileName) else {
            return .failure(.missignFile(fileName))
        }
        return load(fileURL: fileURL, as: type)
    }

    private func load<T>(fileURL: URL, as type: T.Type) -> Result<T, FileLoaderError> where T: Decodable {
        do {
            let data = try Data(contentsOf: fileURL, options: .uncached)
            let response = try jsonDecoder.decode(T.self, from: data)
            return .success(response)
        } catch {
            return .failure(.decodingFailed(error, fileURL))
        }
    }
}
