// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

public enum DerivationType: String, Equatable, CaseIterable {
    case legacy
    case segwit = "bech32"

    var purpose: Int {
        switch self {
        case .legacy:
            44
        case .segwit:
            84
        }
    }

    /// Returns the default derivations, `legacy` and `segwit`
    public static var defaultDerivations: [DerivationType] = [.legacy, .segwit]
}

public struct Derivation: Equatable {
    public let type: DerivationType?
    public let purpose: Int?
    public let xpriv: String?
    public let xpub: String?
    public let addressLabels: [AddressLabel]
    public let cache: AddressCache

    /// Returns `true` if important properties are missing, otherwise false
    public var needsReplenishment: Bool {
        xpub.isNilOrEmpty || xpriv.isNilOrEmpty || type.isNil || purpose.isNil
    }

    public init(
        type: DerivationType?,
        purpose: Int?,
        xpriv: String?,
        xpub: String?,
        addressLabels: [AddressLabel],
        cache: AddressCache
    ) {
        self.type = type
        self.purpose = purpose
        self.xpriv = xpriv
        self.xpub = xpub
        self.addressLabels = addressLabels
        self.cache = cache
    }
}

// MARK: - Creation Methods

/// Creates a `Derivation`.
/// - Parameters:
///   - privateKey: A `PrivateKey` created from a seedHex
///   - type: A `DerivationType`
/// - Returns: `Derivation`
func createDerivation(
    privateKey: PrivateKey,
    type: DerivationType
) -> Derivation {
    Derivation(
        type: type,
        purpose: type.purpose,
        xpriv: privateKey.xpriv,
        xpub: privateKey.xpub,
        addressLabels: [],
        cache: createAddressCache(from: privateKey)
    )
}

/// Creates a array of `Derivation`s using the types found in `DerivationType`
/// - Parameters:
///   - masterNode: A `String` to be used as the master node
///   - index: An `Int` for the private key derivation
/// - Returns: `Result<[Derivation], WalletCreateError>`
func generateDerivations(
    masterNode: String,
    index: Int
) -> [Derivation] {
    DerivationType.defaultDerivations
        .map { type in
            generateDerivation(type: type, index: index, masterNode: masterNode)
        }
}

/// Creates a `Derivation`
/// - Parameters:
///   - type: A `DerivationType`
///   - index: An `Int` for the private key derivation
///   - masterNode: A `String` to be used as a seed hex
/// - Returns: `Derivation`
func generateDerivation(
    type: DerivationType,
    index: Int,
    masterNode: String
) -> Derivation {
    let key = deriveAccountKey(at: index, masterNode: masterNode, type: type)
    return createDerivation(privateKey: key, type: type)
}

/// Derives a `PrivateKey` of path `m/(purpose)'/0'/(index)'`
/// - Parameters:
///   - index: An `Int` representing the _account_index_ to be used
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - type: A `DerivationType` to extract its _purpose_
/// - Returns: A `PrivateKey`
func deriveAccountKey(
    at index: Int,
    masterNode: String,
    type: DerivationType
) -> PrivateKey {
    deriveMasterAccountKey(masterNode: masterNode, type: type)
        .derive(at: .hardened(UInt32(index)))
}

/// Derives a `PrivateKey` of path `m/(purpose)'/0'`
/// - Parameters:
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - type: A `DerivationType` to extract its _purpose_
/// - Returns: A `PrivateKey`
func deriveMasterAccountKey(
    masterNode: String,
    type: DerivationType
) -> PrivateKey {
    PrivateKey.bitcoinKeyFrom(seedHex: masterNode)
        .derive(at: .hardened(UInt32(type.purpose)))
        .derive(at: .hardened(0))
}

/// Derives a `PrivateKey` from the master node at the given derivation path.
/// - Parameters:
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - derivationPath: A `String` to extract its _purpose_
/// - Returns: A `PrivateKey`, or nil if the derivation path is invalid.
func derivePrivateKey(
    masterNode: String,
    derivationPath: String
) -> PrivateKey? {
    guard let hdKeyPath = HDKeyPath(derivationPath) else {
        return nil
    }
    return PrivateKey
        .bitcoinKeyFrom(seedHex: masterNode)
        .derive(at: hdKeyPath)
}

/// Derives a `PrivateKey` from the master node at the given derivation path.
/// - Parameters:
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - derivationPath: A `String` to extract its _purpose_
/// - Returns: A `Data` object, or nil if the derivation path is invalid.
func derivePrivateKeyData(
    masterNode: String,
    derivationPath: String
) -> Data? {
    derivePrivateKey(
        masterNode: masterNode,
        derivationPath: derivationPath
    )?.raw
}

/// Derives a `PublicKey` from the master node at the given derivation path.
/// - Parameters:
///   - masterNode: A `String` to be used as a master node (BIP39 seed)
///   - derivationPath: A `String` to extract its _purpose_
/// - Returns: A `Data` object, or nil if the derivation path is invalid.
func derivePublicKeyData(
    masterNode: String,
    derivationPath: String
) -> Data? {
    let privateKey = derivePrivateKey(
        masterNode: masterNode,
        derivationPath: derivationPath
    )
    return privateKey?.compressedPublicKey
}
