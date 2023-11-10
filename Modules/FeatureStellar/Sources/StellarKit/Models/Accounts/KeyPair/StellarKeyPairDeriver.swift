// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import stellarsdk

final class StellarKeyPairDeriver {

    func derive(input: StellarKeyDerivationInput) -> Result<StellarKeyPair, Error> {
        let keyPair: stellarsdk.KeyPair
        do {
            keyPair = try stellarsdk.Wallet.createKeyPair(
                mnemonic: input.mnemonic,
                passphrase: input.passphrase,
                index: input.index
            )
        } catch {
            return .failure(error)
        }
        return .success(keyPair.stellarKeyPair)
    }
}

extension stellarsdk.KeyPair {
    fileprivate var stellarKeyPair: StellarKeyPair {
        StellarKeyPair(
            accountID: publicKey.accountId,
            publicKey: publicKey.bytes.toHexString(),
            secret: secretSeed
        )
    }
}
