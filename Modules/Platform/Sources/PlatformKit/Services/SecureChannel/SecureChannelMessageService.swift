// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit

public enum MessageError: LocalizedError, Equatable {
    case decryptionFailed
    case encryptionFailed
    case jsonEncodingError

    public var errorDescription: String? {
        switch self {
        case .decryptionFailed:
            "Message Error: Decryption failed."
        case .encryptionFailed:
            "Message Error: Encryption failed."
        case .jsonEncodingError:
            "Message Error: Error encoding JSON data."
        }
    }
}

final class SecureChannelMessageService {

    func decryptMessage(
        _ message: String,
        publicKey: Data,
        deviceKey: Data
    ) -> Result<SecureChannel.BrowserMessage, MessageError> {
        Result {
            let channelKey = try ECDH.derive(priv: deviceKey, pub: publicKey).get()
            let decrypted = try ECDH.decrypt(priv: channelKey, payload: Data(hex: message)).get()
            let decoder = JSONDecoder()
            return try decoder.decode(SecureChannel.BrowserMessage.self, from: decrypted)
        }
        .replaceError(with: MessageError.decryptionFailed)
    }

    func buildMessage(
        message: some Encodable,
        channelId: String,
        success: Bool,
        publicKey: Data,
        deviceKey: Data
    ) -> Result<SecureChannel.PairingResponse, MessageError> {
        Result { try JSONEncoder().encode(message) }
            .replaceError(with: .jsonEncodingError)
            .flatMap { serialisedData in
                buildMessage(
                    data: serialisedData,
                    channelId: channelId,
                    success: success,
                    publicKey: publicKey,
                    deviceKey: deviceKey
                )
            }
    }

    func buildMessage(
        data: Data,
        channelId: String,
        success: Bool,
        publicKey: Data,
        deviceKey: Data
    ) -> Result<SecureChannel.PairingResponse, MessageError> {
        Result {
            let devicePublicKey = try ECDH.publicFromPrivate(priv: deviceKey).get()
            let channelKey = try ECDH.derive(priv: deviceKey, pub: publicKey).get()
            let encrypted = try ECDH.encrypt(priv: channelKey, payload: data).get()
            return SecureChannel.PairingResponse(
                channelId: channelId,
                pubkey: devicePublicKey.hexValue,
                success: success,
                message: encrypted.hexValue
            )
        }
        .replaceError(with: MessageError.encryptionFailed)
    }
}
