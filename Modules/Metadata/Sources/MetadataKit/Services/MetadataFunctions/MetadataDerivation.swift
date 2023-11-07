// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CryptoKit
import Foundation
import MetadataHDWalletKit
import ToolKit

public enum MetadataDerivationError: LocalizedError, Equatable {
    case derivationFailed

    public var errorDescription: String? {
        switch self {
        case .derivationFailed:
            "Could not derive from given purpose"
        }
    }
}

struct MetadataDerivation {

    private enum Contants {
        static let domain = "info.blockchain"
    }

    fileprivate enum Subs {
        static let metadata = "metadata"
        static let mdid = "mdid"
    }

    func deriveMetadataNode(
        node: MasterKey
    ) -> Result<PrivateKey, MetadataDerivationError> {
        getPath(from: Subs.metadata)
            .map { path -> PrivateKey in
                node.privateKey.derive(at: path)
            }
    }

    func deriveSharedMetadataNode(
        node: MasterKey
    ) -> Result<PrivateKey, MetadataDerivationError> {
        getPath(from: Subs.mdid)
            .map { path -> PrivateKey in
                node.privateKey.derive(at: path)
            }
    }

    func deriveAddress(key: PrivateKey) -> String {
        key.address
    }

    private func getPath(from sub: String) -> Result<HDKeyPath, MetadataDerivationError> {
        getPurpose(sub: sub)
            .flatMap { purpose -> Result<HDKeyPath, MetadataDerivationError> in
                HDKeyPath.from(component: .hardened(purpose))
                    .replaceError(with: MetadataDerivationError.derivationFailed)
            }
    }

    private func getPurpose(sub: String) -> Result<UInt32, MetadataDerivationError> {
        purposeHash(sub: sub)
            .flatMap { hash -> Result<UInt32, MetadataDerivationError> in
                purpose(from: hash)
            }
    }

    private func purposeHash(sub: String) -> Result<Data, MetadataDerivationError> {
        let domain = "\(Contants.domain).\(sub)"
        let domainData = Data(domain.utf8)
        let hash = CryptoKit.SHA256.hash(data: domainData)
        return .success(Data(hash))
    }

    /// Parse 4 bytes from the data (starting at the offset) as unsigned 32-bit integer in Big Endian format.
    /// - Parameter hash: A hash of the key of length > 4 bytes
    /// - Returns: A Result of bytes or MetadataDerivationError
    private func purpose(from hash: Data) -> Result<UInt32, MetadataDerivationError> {
        // 510742 for "info.blockchain.metadata"
        hash.readUInt32BigEndian(4)
            .map { $0 & 0x7fffffff }
    }
}

extension Data {

    fileprivate func readUInt32BigEndian(_ position: Int) -> Result<UInt32, MetadataDerivationError> {
        guard count >= position else {
            return .failure(.derivationFailed)
        }
        var blocks: UInt32 = 0
        (self as NSData).getBytes(&blocks, length: position)
        return .success(NSSwapBigIntToHost(blocks))
    }
}
