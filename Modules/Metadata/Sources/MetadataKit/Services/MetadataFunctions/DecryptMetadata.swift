// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum DecryptMetadataError: LocalizedError {
    case invalidPayload
    case failedToDecryptWithRegularKey(payload: Data, validationError: JSONValidationError)
    case failedToDecrypt(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidPayload:
            "Invalid Payload"
        case .failedToDecryptWithRegularKey:
            "Invalid JSON found after decryption"
        case .failedToDecrypt(let error):
            error.localizedDescription
        }
    }
}

func decryptMetadata(
    metadata: MetadataNode,
    payload: String
) -> Result<String, DecryptMetadataError> {

    func decrypt(
        with key: Data,
        payload: String
    ) -> Result<String, DecryptMetadataError> {
        Result<String, DecryptMetadataError>.success(payload)
            .flatMap { payload -> Result<Data, DecryptMetadataError> in
                guard let data = Data(base64Encoded: payload) else {
                    return .failure(.invalidPayload)
                }
                return .success(data)
            }
            .flatMap { payloadData -> Result<String, DecryptMetadataError> in
                AESUtil.decryptWith(key: key, payload: payloadData)
                    .mapError(DecryptMetadataError.failedToDecrypt)
                    .map(String.decodeFromUTF8(codeUnits:))
                    .flatMap { decryptedJSON -> Result<String, DecryptMetadataError> in
                        validateJSON(jsonString: decryptedJSON)
                            .mapError { error -> DecryptMetadataError in
                                .failedToDecryptWithRegularKey(
                                    payload: payloadData,
                                    validationError: error
                                )
                            }
                    }
            }
    }

    func decrypt(
        with key: Data,
        unpaddedKey: Data,
        payload: String
    ) -> Result<String, DecryptMetadataError> {
        decrypt(with: key, payload: payload)
            .flatMapError { error -> Result<String, DecryptMetadataError> in
                guard case .failedToDecryptWithRegularKey(let payloadData, _) = error else {
                    return .failure(error)
                }
                return AESUtil.decryptWith(key: unpaddedKey, payload: payloadData)
                    .mapError(DecryptMetadataError.failedToDecrypt)
                    .map(String.decodeFromUTF8(codeUnits:))
            }
    }

    guard let unpaddedKey = metadata.unpaddedEncryptionKey else {
        return decrypt(with: metadata.encryptionKey, payload: payload)
    }

    return decrypt(
        with: metadata.encryptionKey,
        unpaddedKey: unpaddedKey,
        payload: payload
    )
}

public enum JSONValidationError: Error, Equatable {
    case invalidJSON
}

func validateJSON(jsonString: String) -> Result<String, JSONValidationError> {
    guard let data = jsonString.data(using: .utf8) else {
        return .failure(.invalidJSON)
    }
    return Result { try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) }
        .mapError { _ in .invalidJSON }
        .map { _ in jsonString }
}
