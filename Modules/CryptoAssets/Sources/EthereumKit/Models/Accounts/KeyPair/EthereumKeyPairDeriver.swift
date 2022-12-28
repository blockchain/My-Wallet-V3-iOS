// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import WalletCore

struct EthereumKeyPairDeriver {

    func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, HDWalletError> {
        let ethereumCoinType = CoinType.ethereum
        // Hardcoding BIP39 passphrase as empty string as it is currently not  supported.
        guard let hdWallet = HDWallet(mnemonic: input.mnemonic, passphrase: "") else {
            return .failure(.walletFailedToInitialise())
        }
        let address = hdWallet.getAddressForCoin(coin: ethereumCoinType)
        let privateKey = hdWallet.getKeyForCoin(coin: ethereumCoinType)
        let publicKey = privateKey.getPublicKeySecp256k1(compressed: false).data.hexString
        let ethereumPrivateKey = EthereumPrivateKey(
            mnemonic: input.mnemonic,
            data: privateKey.data
        )
        let keyPair = EthereumKeyPair(
            address: address,
            publicKey: publicKey,
            privateKey: ethereumPrivateKey
        )
        return .success(keyPair)
    }
}
