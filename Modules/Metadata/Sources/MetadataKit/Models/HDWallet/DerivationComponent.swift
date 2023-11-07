// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit

extension CharacterSet {

    fileprivate static var integers: CharacterSet {
        CharacterSet(charactersIn: "0123456789")
    }
}

public enum DerivationComponent {
    case hardened(UInt32)
    case normal(UInt32)

    public var description: String {
        switch self {
        case .normal(let index):
            "\(index)"
        case .hardened(let index):
            "\(index)'"
        }
    }

    public var isHardened: Bool {
        switch self {
        case .normal:
            false
        case .hardened:
            true
        }
    }

    var derivationNode: DerivationNode {
        switch self {
        case .normal(let value):
            .notHardened(value)
        case .hardened(let value):
            .hardened(value)
        }
    }

    init?(item: String) {
        let hardened = item.hasSuffix("'")
        let indexString = item.trimmingCharacters(in: CharacterSet.integers.inverted)
        guard let index = UInt32(indexString) else {
            return nil
        }
        guard hardened else {
            self = .normal(index)
            return
        }
        self = .hardened(index)
    }

    func from(_ component: MetadataHDWalletKit.DerivationNode) -> Self {
        switch component {
        case .hardened(let index):
            .hardened(index)
        case .notHardened(let index):
            .normal(index)
        }
    }
}

extension [DerivationComponent] {

    public func with(normal index: UInt32) -> Self {
        self + [.normal(index)]
    }

    public func with(hardened index: UInt32) -> Self {
        self + [.hardened(index)]
    }

    public var path: String {
        "m/" + map(\.description).joined(separator: "/")
    }
}
