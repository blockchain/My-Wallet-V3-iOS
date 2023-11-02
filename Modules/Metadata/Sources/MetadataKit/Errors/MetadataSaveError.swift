// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataSaveError: FromEncodingError {
    case saveFailed(SaveMetadataError)
    case encodingError(EncodingError)

    public static func from(_ encodingError: EncodingError) -> Self {
        .encodingError(encodingError)
    }

    public var errorDescription: String? {
        switch self {
        case .saveFailed(let saveMetadataError):
            saveMetadataError.errorDescription
        case .encodingError(let encodingError):
            encodingError.formattedDescription
        }
    }
}
