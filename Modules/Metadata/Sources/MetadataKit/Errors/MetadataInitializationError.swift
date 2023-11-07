// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitialisationError: LocalizedError, Equatable {
    case failedToDeriveSecondPasswordNode(DeriveSecondPasswordNodeError)
    case failedToLoadRemoteMetadataNode(LoadRemoteMetadataError)
    case failedToDecodeRemoteMetadataNode(DecodingError)
    case failedToDeriveRemoteMetadataNode(MetadataInitError)
    case failedToGenerateNodes(Error)

    public static func == (lhs: MetadataInitialisationError, rhs: MetadataInitialisationError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToDeriveSecondPasswordNode(let leftError), .failedToDeriveSecondPasswordNode(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        case (.failedToLoadRemoteMetadataNode(let leftError), .failedToLoadRemoteMetadataNode(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        case (.failedToDecodeRemoteMetadataNode(let leftError), .failedToDecodeRemoteMetadataNode(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        case (.failedToDeriveRemoteMetadataNode(let leftError), .failedToDeriveRemoteMetadataNode(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        case (.failedToGenerateNodes(let leftError), .failedToGenerateNodes(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        default:
            false
        }
    }

    public var errorDescription: String? {
        switch self {
        case .failedToDeriveSecondPasswordNode(let deriveSecondPasswordNodeError):
            deriveSecondPasswordNodeError.errorDescription
        case .failedToLoadRemoteMetadataNode(let loadRemoteMetadataError):
            loadRemoteMetadataError.errorDescription
        case .failedToDecodeRemoteMetadataNode(let decodingError):
            decodingError.formattedDescription
        case .failedToDeriveRemoteMetadataNode(let metadataInitError):
            metadataInitError.errorDescription
        case .failedToGenerateNodes(let error):
            error.localizedDescription
        }
    }
}
