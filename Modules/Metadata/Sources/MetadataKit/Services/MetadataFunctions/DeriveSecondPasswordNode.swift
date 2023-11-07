// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import struct CryptoKit.SHA256
import Foundation
import MetadataHDWalletKit

typealias DeriveSecondPasswordNode =
    (Credentials) -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError>

public enum DeriveSecondPasswordNodeError: LocalizedError, Equatable {
    case privateKeyInstantiationFailed

    public var errorDescription: String? {
        switch self {
        case .privateKeyInstantiationFailed:
            "Private Key couldn't not be retrieved"
        }
    }
}

func deriveSecondPasswordNode(
    credentials: Credentials
) -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError> {
    deriveSecondPasswordNode(
        guid: credentials.guid,
        sharedKey: credentials.sharedKey,
        password: credentials.password
    )
}

private func deriveSecondPasswordNode(
    guid: String,
    sharedKey: String,
    password: String
) -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError> {
    secondPasswordNodeEntropyHex(
        guid: guid,
        sharedkey: sharedKey,
        password: password
    )
    .flatMap { entropyHex -> Result<PrivateKey, DeriveSecondPasswordNodeError> in
        privateKeyFromEntropyHex(entropyHex: entropyHex)
    }
    .flatMap { privateKey -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError> in
        secondPasswordNodeFrom(privateKey: privateKey)
    }
}

private func secondPasswordNodeEntropyHex(
    guid: String,
    sharedkey: String,
    password: String
) -> Result<String, DeriveSecondPasswordNodeError> {
    .success(guid + sharedkey + password)
        .map(Data.from(utf8string:))
        .map { data in
            CryptoKit.SHA256.hash(data: data)
        }
        .map { sha256Digest -> String in
            sha256Digest.compactMap { String(format: "%02x", $0) }.joined()
        }
}

private func privateKeyFromEntropyHex(
    entropyHex: String
) -> Result<PrivateKey, DeriveSecondPasswordNodeError> {
    guard let key = PrivateKey.bitcoinKeyFrom(privateKeyHex: entropyHex) else {
        return .failure(.privateKeyInstantiationFailed)
    }
    return .success(key)
}

private func secondPasswordNodeFrom(
    privateKey: PrivateKey
) -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError> {
    let node = MetadataNode(
        address: privateKey.address,
        node: privateKey,
        encryptionKey: privateKey.raw,
        type: .root
    )
    return Result<MetadataNode, DeriveSecondPasswordNodeError>.success(node)
        .map(SecondPasswordNode.init(metadataNode:))
}
