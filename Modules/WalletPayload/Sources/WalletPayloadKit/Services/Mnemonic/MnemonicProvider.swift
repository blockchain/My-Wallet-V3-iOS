// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletCore

public enum MnemonicProviderError: Error, Equatable {
    case unableToProvide
    case entropyFailure(RNGEntropyError)
}

/// Defines the strength of the mnemonic in bits
/// The entropy should be between **128 and 256 bits**
enum MnemonicStrength {
    case normal
    case high

    var value: Int {
        switch self {
        case .normal:
            128
        case .high:
            256
        }
    }

    /// The bytes of the strength
    var bytes: Int {
        value / 8
    }
}

/// Provides a Mnemonic by passing an entropy to `WalletCore.HDWallet`.
/// - Parameters:
///   - strength: A `MnemonicStrength` for the entropy
///   - entropyProvider: An entropy provider which generates a random number
/// - Returns: `AnyPublisher<String, MnemonicProviderError>`
func provideMnemonic(
    strength: MnemonicStrength,
    queue: DispatchQueue,
    entropyProvider: @escaping EntropyProvider
) -> AnyPublisher<String, MnemonicProviderError> {
    entropyProvider(strength.bytes)
        .receive(on: queue)
        .mapError(MnemonicProviderError.entropyFailure)
        .flatMap { entropy -> AnyPublisher<String, MnemonicProviderError> in
            guard let wallet = WalletCore.HDWallet(entropy: entropy, passphrase: "") else {
                return .failure(.unableToProvide)
            }
            return .just(wallet.mnemonic)
        }
        .eraseToAnyPublisher()
}
