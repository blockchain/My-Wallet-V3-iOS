// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum MasterKeyError: LocalizedError, Equatable {
    case failedToInstantiate(Error)

    public static func == (lhs: MasterKeyError, rhs: MasterKeyError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToInstantiate(let leftError), .failedToInstantiate(let rightError)):
            leftError.localizedDescription == rightError.localizedDescription
        }
    }

    public var errorDescription: String? {
        switch self {
        case .failedToInstantiate(let error):
            error.localizedDescription
        }
    }
}

public struct MasterKey: Equatable {

    let privateKey: PrivateKey
}

extension MasterKey {

    public static func from(
        masterNode: String
    ) -> Result<MasterKey, MasterKeyError> {
        Result<PrivateKey, MasterKeyError>
            .success(PrivateKey.bitcoinKeyFrom(seedHex: masterNode))
            .mapError(MasterKeyError.failedToInstantiate)
            .map(MasterKey.init(privateKey:))
    }
}
