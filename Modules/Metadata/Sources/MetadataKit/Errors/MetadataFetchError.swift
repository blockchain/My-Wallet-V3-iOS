// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataFetchError: FromDecodingError, Equatable {
    case loadMetadataError(LoadRemoteMetadataError)
    case failedToDeriveMetadataNode(MetadataNodeError)
    case decodingError(DecodingError)

    public static func from(_ decodingError: DecodingError) -> Self {
        .decodingError(decodingError)
    }

    public static func == (lhs: MetadataFetchError, rhs: MetadataFetchError) -> Bool {
        switch (lhs, rhs) {
        case (.loadMetadataError(let leftError), .loadMetadataError(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        case (.failedToDeriveMetadataNode(let leftError), .failedToDeriveMetadataNode(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        case (.decodingError(let leftError), .decodingError(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        default:
            false
        }
    }

    public var errorDescription: String? {
        switch self {
        case .loadMetadataError(let loadRemoteMetadataError):
            loadRemoteMetadataError.errorDescription
        case .failedToDeriveMetadataNode(let metadataNodeError):
            metadataNodeError.localizedDescription
        case .decodingError(let decodingError):
            decodingError.formattedDescription
        }
    }
}
