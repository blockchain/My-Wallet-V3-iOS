// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit
import WalletPayloadKit

/// A collection of XPub addresses.
public struct XPubs: Equatable {
    public let xpubs: [XPub]

    public var `default`: XPub {
        bech32
    }

    private var bech32: XPub {
        xpubs.first { $0.derivationType == .bech32 }!
    }

    private var legacy: XPub {
        xpubs.first { $0.derivationType == .legacy }!
    }

    public init(xpubs: [XPub]) {
        self.xpubs = xpubs
    }
}

/// A single XPub address.
public struct XPub: Equatable, Hashable {
    public let address: String
    public let derivationType: DerivationType

    public init(address: String, derivationType: DerivationType) {
        self.address = address
        self.derivationType = derivationType
    }
}

public enum DerivationType: String, Decodable, CaseIterable {
    case legacy
    case bech32

    public var isSegwit: Bool {
        switch self {
        case .bech32:
            return true
        case .legacy:
            return false
        }
    }

    var purpose: UInt32 {
        switch self {
        case .bech32:
            return 84
        case .legacy:
            return 44
        }
    }
}

public func derivationType(from type: WalletPayloadKit.DerivationType) -> BitcoinChainKit.DerivationType {
    switch type {
    case .legacy:
        return .legacy
    case .segwit:
        return .bech32
    }
}
