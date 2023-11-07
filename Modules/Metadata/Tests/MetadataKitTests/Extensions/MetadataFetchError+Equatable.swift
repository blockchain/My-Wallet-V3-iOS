// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

extension LoadRemoteMetadataError: Equatable {

    public static func == (
        lhs: LoadRemoteMetadataError,
        rhs: LoadRemoteMetadataError
    ) -> Bool {
        switch (lhs, rhs) {
        case (.notYetCreated, .notYetCreated):
            true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            lhsError == rhsError
        case (.decryptionFailed(let lhsError), .decryptionFailed(let rhsError)):
            lhsError == rhsError
        default:
            false
        }
    }
}

extension DecryptMetadataError: Equatable {

    public static func == (
        lhs: DecryptMetadataError,
        rhs: DecryptMetadataError
    ) -> Bool {
        switch (lhs, rhs) {
        case (.invalidPayload, .invalidPayload):
            true
        case (
            .failedToDecryptWithRegularKey(
                let lhsPayload, let lhsValidationError
            ),
            .failedToDecryptWithRegularKey(
                let rhsPayload, let rhsValidationError
            )
        ):
            lhsPayload == rhsPayload && lhsValidationError == rhsValidationError
        case (.failedToDecrypt(let lhsError), .failedToDecrypt(let rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}
