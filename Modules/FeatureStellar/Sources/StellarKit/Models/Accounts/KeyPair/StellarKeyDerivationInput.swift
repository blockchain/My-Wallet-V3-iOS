// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct StellarKeyDerivationInput {
    /// The mnemonic phrase used to derive the key pair
    let mnemonic: String

    /// An optional passphrase for deriving the key pair
    let passphrase: String? = nil

    /// The index of the wallet
    let index: Int = 0

    init(mnemonic: String) {
        self.mnemonic = mnemonic
    }
}
