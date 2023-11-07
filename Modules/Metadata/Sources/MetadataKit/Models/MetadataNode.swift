// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataNodeError: LocalizedError {
    case typeIndexMustBePositive

    public var errorDescription: String? {
        switch self {
        case .typeIndexMustBePositive:
            "Metadata Node failure,:type index must be a positive number"
        }
    }
}

struct MetadataNode: Equatable {

    let address: String

    let node: PrivateKey

    let encryptionKey: Data

    let unpaddedEncryptionKey: Data?

    let type: EntryType

    init(
        address: String,
        node: PrivateKey,
        encryptionKey: Data,
        unpaddedEncryptionKey: Data? = nil,
        type: EntryType
    ) {
        self.address = address
        self.node = node
        self.encryptionKey = encryptionKey
        self.unpaddedEncryptionKey = unpaddedEncryptionKey
        self.type = type
    }
}

extension MetadataNode {

    static func from(
        metaDataHDNode: PrivateKey,
        metadataDerivation: MetadataDerivation,
        for type: EntryType
    ) -> Result<MetadataNode, MetadataNodeError> {

        guard type.rawValue >= 0 else {
            return .failure(.typeIndexMustBePositive)
        }

        let typeIndex = UInt32(type.rawValue)
        let payloadTypeNode = MetadataUtil.deriveHardened(
            node: metaDataHDNode,
            type: typeIndex
        )

        let newNode = MetadataUtil.deriveHardened(
            node: payloadTypeNode,
            type: 0
        )

        let keyBytes = MetadataUtil
            .deriveHardened(
                node: payloadTypeNode,
                type: 1
            )
            .raw

        let keyBytesUnpadded: Data? = {
            guard let firstNonZeroByte = keyBytes.firstIndex(where: { $0 != 0 }) else {
                return nil
            }
            return keyBytes[firstNonZeroByte...]
        }()

        let address = metadataDerivation.deriveAddress(key: newNode)

        let encryptionKey = keyBytes.sha256()

        let unpaddedEncryptionKey = keyBytesUnpadded?.sha256()

        let metadata = MetadataNode(
            address: address,
            node: newNode,
            encryptionKey: encryptionKey,
            unpaddedEncryptionKey: unpaddedEncryptionKey,
            type: type
        )

        return .success(metadata)
    }
}

#if DEBUG
extension MetadataNode: CustomDebugStringConvertible {

    public var debugDescription: String {
        """
        MetadataNode(
            address: \(address.debugDescription),
            node: \(node.debugDescription),
            encryptionKey: \(encryptionKey.hex),
            unpaddedEncryptionKey: \(unpaddedEncryptionKey?.hex ?? "nil"),
            type: \(type)
        )
        """
    }
}
#endif
