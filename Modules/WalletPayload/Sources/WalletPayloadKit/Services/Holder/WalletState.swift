// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

/// An internal enum keeping track of the current state of `Wrapper & Wallet` and `MetadataState`
///
/// - note: The app requires both the `Wallet` model and `MetadataState` to be available in order to function correctly.
///
/// Accessing the wallet can happen using the following methods:
/// 1. Create a brand new Wallet and Metadata and sync with server
/// 2. Recover Account (using seed phrase, aka mnemonic)
///    - Using the seed phrase we initialize the metadata which contains the necessary info to login into an account
///    this makes the `MetadataState` available before having the `Wrapper`.
/// 3. Login using pin (previously logged in)
///    - Using the pin we have already fetched the `Wrapper`, after we decrypt using the password we store it
///    and then initialize the `MetadataState`
///
public enum WalletState: Equatable {
    public enum PartiallyLoaded: Equatable {
        case justMetadata(MetadataState)
        case justWrapper(Wrapper)
    }

    case partially(loaded: PartiallyLoaded)
    case loaded(wrapper: Wrapper, metadata: MetadataState)

    /// Returns `true` if both metadata and wallet has been initialized, otherwise `false`
    public var isInitialised: Bool {
        isMetadataInitialised && walletInitialized
    }

    public var wrapper: Wrapper? {
        switch self {
        case .partially(loaded: .justWrapper(let wrapper)):
            wrapper
        case .partially(loaded: .justMetadata):
            nil
        case .loaded(wrapper: let wrapper, _):
            wrapper
        }
    }

    public var wallet: NativeWallet? {
        wrapper?.wallet
    }

    public var metadata: MetadataState? {
        switch self {
        case .partially(loaded: .justWrapper):
            nil
        case .partially(loaded: .justMetadata(let metadata)):
            metadata
        case .loaded(_, metadata: let metadata):
            metadata
        }
    }

    public var isMetadataInitialised: Bool {
        metadata != nil
    }

    public var walletInitialized: Bool {
        wallet != nil
    }
}
